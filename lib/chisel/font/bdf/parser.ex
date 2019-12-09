defmodule Chisel.Font.BDF.Parser do
  @moduledoc false

  alias Chisel.Font
  alias Chisel.Font.Glyph

  defstruct font: nil, props?: nil, total_chars: nil, char: nil, glyphs: nil

  def parse!(tokens, opts \\ []) do
    default_name = Keyword.get(opts, :default_name, "noname-font")

    tokens
    |> build_lines()
    |> reject_comments()
    |> do_parse
    |> finish_font()
    |> ensure_offset()
    |> ensure_size()
    |> ensure_name(default_name)
  end

  defp ensure_name({:ok, %Font{name: nil} = font}, default),
    do: {:ok, %{font | name: default}}

  defp ensure_name(res, _filename),
    do: res

  defp ensure_offset({:ok, %Font{offset: nil} = font}),
    do: {:ok, %{font | offset: {0, 0}}}

  defp ensure_offset(res),
    do: res

  defp ensure_size({:ok, %Font{size: nil, glyphs: glyphs} = font}) do
    size =
      Enum.reduce(glyphs, {0, 0}, fn {_, %{size: {w, h}, offset: {ox, oy}}}, {cw, ch} ->
        cw1 = max(w + ox, cw)
        ch1 = max(h + oy, ch)

        {cw1, ch1}
      end)

    {:ok, %{font | size: size}}
  end

  defp ensure_size(res),
    do: res

  defp reject_comments(tokens) do
    Stream.reject(tokens, fn
      {:keyword, n, _, _} -> n == "COMMENT"
      _ -> false
    end)
  end

  defp do_parse(tokens),
    do: Enum.reduce_while(tokens, create_context(), &do_parse/2)

  defp do_parse({:keyword, "STARTFONT", _version, _}, %{char: nil} = context),
    do: continue(context)

  defp do_parse({:keyword, "ENDFONT", [], _}, %{char: nil} = context) do
    context
    |> finish_font()
    |> continue()
  end

  defp do_parse({:keyword, "FONT", name, _}, %{char: nil} = context),
    do: continue(%{context | font: %{context.font | name: Enum.join(name)}})

  defp do_parse({:keyword, "SIZE", [_, _, _], _}, %{char: nil} = context),
    do: continue(context)

  defp do_parse({:keyword, "STARTPROPERTIES", [_], _}, %{char: nil} = context),
    do: continue(%{context | props?: true})

  defp do_parse({:keyword, "ENDPROPERTIES", [], _}, %{props?: true} = context),
    do: continue(%{context | props?: nil})

  defp do_parse(_, %{props?: true} = context),
    do: continue(%{context | props?: true})

  defp do_parse({:keyword, "CHARS", [total], _}, %{char: nil} = context),
    do: continue(%{context | total_chars: parse_int!(total)})

  defp do_parse({:keyword, "FONTBOUNDINGBOX", args, _}, %{char: nil} = context) do
    [w, h, ox, oy] = parse_int!(args)

    context
    |> update_font(fn font ->
      %{font | size: {w, h}, offset: {ox, oy}}
    end)
    |> continue()
  end

  defp do_parse({:keyword, "STARTCHAR", name, _}, %{char: nil} = context) do
    context
    |> update_char(fn _ -> %Glyph{name: Enum.join(name, " ")} end)
    |> continue()
  end

  defp do_parse({:value, [row], _}, %{char: %Glyph{data: data, size: {gw, gh}}} = context)
       when length(data) < gh do
    bits = trunc(String.length(row) / 2) * 8
    value = parse_int!(row, 16)
    <<row_data::bitstring-size(gw), _::bitstring>> = <<value::big-unsigned-integer-size(bits)>>
    data = [row_data | context.char.data]

    context
    |> update_char(fn char -> %{char | data: data} end)
    |> continue()
  end

  defp do_parse({:keyword, "BITMAP", [], _}, %{char: %Glyph{}} = context) do
    context
    |> update_char(fn char -> %{char | data: []} end)
    |> continue()
  end

  defp do_parse({:keyword, "ENCODING", [codepoint], _}, %{char: %Glyph{}} = context) do
    context
    |> update_char(fn char -> %{char | codepoint: parse_int!(codepoint)} end)
    |> continue()
  end

  defp do_parse({:keyword, "DWIDTH", [dwx, _], _}, %{char: %Glyph{}} = context) do
    dwx1 = parse_int!(dwx)

    context
    |> update_char(fn char -> %{char | dwx: dwx1} end)
    |> continue()
  end

  defp do_parse({:keyword, "SWIDTH", [_, _], _}, %{char: %Glyph{}} = context) do
    continue(context)
  end

  defp do_parse({:keyword, "BBX", args, _}, %{char: %Glyph{}} = context) do
    [w, h, ox, oy] = parse_int!(args)

    context
    |> update_char(fn char ->
      %{char | size: {w, h}, offset: {ox, oy}}
    end)
    |> continue()
  end

  defp do_parse({:keyword, "ENDCHAR", [], _}, %{char: %Glyph{data: data, size: {_, h}}} = context)
       when length(data) == h do
    %{char: char} = context

    char = %{char | data: Enum.reverse(data)}

    context
    |> add_glyph(char)
    |> update_char(fn _ -> nil end)
    |> continue()
  end

  defp do_parse(offense, _),
    do: halt({:error, {:parse, offense}})

  defp finish_font({:ok, %Font{}} = res),
    do: res

  defp finish_font(%__MODULE__{char: nil, glyphs: glyphs} = context) do
    font_glyphs = Map.new(glyphs, fn %{codepoint: k} = v -> {k, v} end)

    %{font: font} =
      context
      |> update_font(fn font ->
        %{font | glyphs: font_glyphs}
      end)

    {:ok, font}
  end

  defp finish_font(_),
    do: {:error, :load}

  defp create_context() do
    %__MODULE__{
      char: nil,
      font: %Font{},
      glyphs: []
    }
  end

  defp continue(context),
    do: {:cont, context}

  defp halt(result),
    do: {:halt, result}

  defp update_char(context, fun),
    do: %{context | char: fun.(context.char)}

  defp add_glyph(context, glyph),
    do: %{context | glyphs: [glyph | context.glyphs]}

  defp update_font(context, fun),
    do: %{context | font: fun.(context.font)}

  defp parse_int!(str, base \\ 10)

  defp parse_int!(strs, base) when is_list(strs),
    do: Enum.map(strs, &parse_int!(&1, base))

  defp parse_int!(str, base) when is_binary(str) do
    case Integer.parse(str, base) do
      {value, ""} -> value
      _ -> raise {:error, {:parse_int, str}}
    end
  end

  ##
  ## build_lines
  ##

  defp build_lines(tokens),
    do: Stream.transform(tokens, [], &build_lines/2)

  defp build_lines({:eol, _, _}, buffer) do
    buffer
    |> Enum.reverse()
    |> do_line()
    |> case do
      nil -> {[], []}
      keyword -> {[keyword], []}
    end
  end

  defp build_lines(token, buffer),
    do: {[], [token | buffer]}

  defp do_line([{:keyword, name, {line, _}} | args]),
    do: {:keyword, name, get_values(args, []), line}

  defp do_line([{:value, _, {line, _}} | _] = values),
    do: {:value, get_values(values, []), line}

  defp do_line([]),
    do: nil

  defp do_line([token | _]),
    do: raise({:error, {:invalid_token, token}})

  defp get_values([], acc),
    do: Enum.reverse(acc)

  defp get_values([{_, value, _} | values], acc),
    do: get_values(values, [value | acc])
end

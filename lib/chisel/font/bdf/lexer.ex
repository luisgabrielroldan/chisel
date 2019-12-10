defmodule Chisel.Font.BDF.Lexer do
  @moduledoc false

  defstruct line: nil, col: nil, buffer: [], tokens: [], in_string?: false, in_comment?: false

  @token_whitespace [" ", "\t", "\r", "\n"]

  @keywords [
    "STARTFONT",
    "COMMENT",
    "FONT",
    "SIZE",
    "FONTBOUNDINGBOX",
    "STARTPROPERTIES",
    "ENDPROPERTIES",
    "CHARS",
    "STARTCHAR",
    "ENCODING",
    "SWIDTH",
    "DWIDTH",
    "BBX",
    "BITMAP",
    "ENDCHAR",
    "ENDFONT"
  ]

  def scan!(stream) do
    context = %__MODULE__{line: 1, col: 1}

    stream
    |> Stream.flat_map(&String.codepoints/1)
    |> Stream.transform(context, fn ch, context1 ->
      {tokens, context1} = parse_char(ch, context1)
      context1 = handle_position(context1, ch)
      {tokens, context1}
    end)
  end

  defp parse_char("\"", %{in_string?: false, buffer: []} = context) do
    context
    |> string_start()
    |> continue()
  end

  defp parse_char("\"", %{in_string?: true} = context) do
    context
    |> string_stop()
    |> buffer_clean()
    |> emit_token(:value, get_buffer(context))
    |> continue()
  end

  defp parse_char(ch, %{in_string?: false, buffer: []} = context) when ch in @token_whitespace do
    context
    |> buffer_clean()
    |> maybe_eol(ch)
    |> continue()
  end

  defp parse_char(ch, %{in_string?: false} = context)
       when ch in @token_whitespace do
    {type, value} =
      context
      |> get_buffer()
      |> detect_token()

    context
    |> emit_token(type, value)
    |> buffer_clean()
    |> maybe_eol(ch)
    |> continue()
  end

  defp parse_char(ch, context) do
    context
    |> append_char(ch)
    |> continue()
  end

  defp detect_token(content) do
    cond do
      content in @keywords ->
        {:keyword, content}

      true ->
        {:value, content}
    end
  end

  defp string_start(ctx),
    do: %{ctx | in_string?: true}

  defp string_stop(ctx),
    do: %{ctx | in_string?: false}

  defp maybe_eol(ctx, "\n"),
    do: emit_token(ctx, :eol, "\n")

  defp maybe_eol(ctx, _ch),
    do: ctx

  defp append_char(%{buffer: buffer} = ctx, ch) do
    %{ctx | buffer: [ch | buffer]}
  end

  defp buffer_clean(ctx),
    do: %{ctx | buffer: []}

  defp get_buffer(%{buffer: buffer}),
    do: Enum.reverse(buffer) |> to_string()

  defp continue(%{tokens: []} = ctx),
    do: {[], ctx}

  defp continue(%{tokens: tokens} = ctx),
    do: {Enum.reverse(tokens), %{ctx | tokens: []}}

  defp emit_token(%{tokens: tokens} = ctx, type, value) do
    token = {type, value, {ctx.line, ctx.col}}

    %{ctx | tokens: [token | tokens]}
  end

  defp handle_position(%{line: line} = ctx, "\n"),
    do: %{ctx | line: line + 1, col: 1}

  defp handle_position(%{col: col} = ctx, _ch),
    do: %{ctx | col: col + 1}

  defp handle_position(ctx, _ch),
    do: ctx
end

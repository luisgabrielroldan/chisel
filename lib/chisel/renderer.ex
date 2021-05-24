defmodule Chisel.Renderer do
  @moduledoc """
  The renderer is capable of draw the text on any target using for that
  a function that receives the x, y coordinates of the pixel to be painted.
  """

  alias Chisel.Font
  alias Chisel.Font.Glyph

  @draw_default_opts [
    size_x: 1,
    size_y: 1
  ]

  @type acc :: any()

  @typedoc """
  Use `size_x` and `size_y` options to scale up the font.
  """
  @type draw_options :: list({:size_x, integer()} | {:size_y, integer})

  @typedoc """
  The function used to paint the canvas.

  Chisel will use this function to draw the text.
  """
  @type pixel_fun :: (x :: integer(), y :: integer() -> term())

  @typedoc """
  The function used to paint the canvas.

  Chisel will use this function to draw the text.
  """
  @type reduce_pixel_fun :: (acc :: acc(), x :: integer(), y :: integer() -> acc())

  @doc """
  Draws an string

  The coordinates (`tlx`, `tly`) are for the top left corner.
  """
  @spec draw_text(
          text :: String.t(),
          tlx :: integer(),
          tly :: integer(),
          font :: Font.t(),
          put_pixel :: pixel_fun,
          opts :: draw_options()
        ) ::
          {x :: integer(), y :: integer()}
  def draw_text(text, tlx, tly, %Font{} = font, put_pixel, opts \\ []) when is_binary(text) do
    reduce_pixel = fn x, y, _ -> put_pixel.(x, y) end

    {_acc, dx, dy} = reduce_draw_text(text, tlx, tly, font, nil, reduce_pixel, opts)

    {dx, dy}
  end

  @doc """
  Draws a character using the codepoint

  The coordinates (`tlx`, `tly`) are for the top left corner.
  """
  @spec draw_char(
          codepoint :: integer(),
          clx :: integer(),
          cly :: integer(),
          font :: Font.t(),
          put_pixel :: pixel_fun,
          opts :: draw_options()
        ) ::
          {x :: integer(), y :: integer()}
  def draw_char(codepoint, clx, cly, %Font{} = font, put_pixel, opts \\ [])
      when is_integer(codepoint) do
    reduce_pixel = fn x, y, _ -> put_pixel.(x, y) end

    {_acc, dx, dy} = reduce_draw_char(codepoint, clx, cly, font, nil, reduce_pixel, opts)

    {dx, dy}
  end

  @doc """
  Draws an string calling a reducer function

  The coordinates (`tlx`, `tly`) are for the top left corner.
  """
  @spec reduce_draw_text(
          text :: String.t(),
          tlx :: integer(),
          tly :: integer(),
          font :: Font.t(),
          acc :: acc(),
          reduce_pixel :: reduce_pixel_fun,
          opts :: draw_options()
        ) ::
          {acc :: acc(), x :: integer(), y :: integer()}
  def reduce_draw_text(text, tlx, tly, %Font{} = font, acc, reduce_pixel, opts \\ [])
      when is_binary(text) do
    opts = Keyword.merge(@draw_default_opts, opts)

    text
    |> to_charlist()
    |> Enum.reduce({acc, tlx, tly}, fn
      char, {acc1, x, y} ->
        case char do
          # Ignore carraige return
          13 ->
            {acc1, x, y}

          # New line
          10 ->
            %{size: {_, font_h}} = font

            {acc1, tlx, y + font_h * opts[:size_y]}

          _ ->
            reduce_draw_char(char, x, y, font, acc1, reduce_pixel, opts)
        end
    end)
  end

  @doc """
  Draws a character using the codepoint calling a reducer function.

  The coordinates (`tlx`, `tly`) are for the top left corner.
  """
  @spec reduce_draw_char(
          codepoint :: integer(),
          clx :: integer(),
          cly :: integer(),
          font :: Font.t(),
          acc :: acc(),
          reduce_pixel :: reduce_pixel_fun,
          opts :: draw_options()
        ) ::
          {acc :: acc(), x :: integer(), y :: integer()}
  def reduce_draw_char(codepoint, clx, cly, %Font{} = font, acc, reduce_pixel, opts \\ [])
      when is_integer(codepoint) do
    opts = Keyword.merge(@draw_default_opts, opts)

    size_x = opts[:size_x]

    %{size: {_, font_h}} = font

    case lookup_glyph(codepoint, font) do
      %Glyph{} = glyph ->
        acc1 = draw_glyph(glyph, clx, cly + font_h, reduce_pixel, opts, acc)

        glyph_dx = glyph.dwx

        {acc1, clx + glyph_dx * size_x, cly}

      _ ->
        {acc, clx, cly}
    end
  end

  @doc """
  Gets the size of the rendered string using the font and options provided
  """
  @spec get_text_width(
          text :: String.t(),
          font :: Font.t(),
          opts :: draw_options()
        ) :: integer()
  def get_text_width(text, %Font{} = font, opts \\ []) when is_binary(text) do
    opts = Keyword.merge(@draw_default_opts, opts)
    size_x = opts[:size_x]

    to_charlist(text)
    |> Enum.reduce(0, fn char, size ->
      case lookup_glyph(char, font) do
        %Glyph{} = glyph ->
          glyph_dx = glyph.dwx

          size + glyph_dx * size_x

        _ ->
          size
      end
    end)
  end

  defp draw_glyph(%Glyph{} = glyph, gx, gy, reduce_pixel, opts, acc) do
    opts = Keyword.merge(@draw_default_opts, opts)

    %{
      data: data,
      size: {bb_w, bb_h},
      offset: {bb_xoff, bb_yoff}
    } = glyph

    x = gx - bb_xoff
    y = gy - bb_yoff - bb_h

    for(<<row::bitstring-size(bb_w) <- data>>, do: row)
    |> Enum.reverse()
    |> do_render_glyph({x, y}, reduce_pixel, opts, acc)
  end

  defp do_render_glyph(rows, pos, reduce_pixel, opts, acc, iy \\ 0)

  defp do_render_glyph([], _pos, _put_pixel, _opts, acc, _iy),
    do: acc

  defp do_render_glyph([row | rows], pos, reduce_pixel, opts, acc, iy) do
    acc = render_glyph_row(row, pos, iy, reduce_pixel, opts, acc)

    do_render_glyph(rows, pos, reduce_pixel, opts, acc, iy + opts[:size_y])
  end

  defp render_glyph_row(row, pos, iy, reduce_pixel, opts, acc, ix \\ 0)

  defp render_glyph_row(<<>>, _pos, _iy, _put_pixel, _opts, acc, _ix),
    do: acc

  defp render_glyph_row(<<1::1, rest::bitstring>>, pos, iy, reduce_pixel, opts, acc, ix) do
    {x, y} = pos

    acc =
      for(ox <- 0..(opts[:size_x] - 1), oy <- 0..(opts[:size_y] - 1), do: {ox, oy})
      |> Enum.reduce(acc, fn {ox, oy}, acc1 ->
        reduce_pixel.(x + ix + ox, y + iy + oy, acc1)
      end)

    render_glyph_row(rest, pos, iy, reduce_pixel, opts, acc, ix + opts[:size_x])
  end

  defp render_glyph_row(<<_::1, rest::bitstring>>, pos, iy, reduce_pixel, opts, acc, ix),
    do: render_glyph_row(rest, pos, iy, reduce_pixel, opts, acc, ix + opts[:size_x])

  defp lookup_glyph(char, font),
    do: Map.get(font.glyphs, char)
end

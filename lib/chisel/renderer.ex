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

  @type draw_option :: {:size_x, integer()} | {:size_y, integer}

  @typedoc """
  Use `size_x` and `size_y` options to scale up the font.
  """
  @type draw_options :: list(draw_option)

  @typedoc """
  The function used to paint the canvas.

  Chisel will use this function to draw the text.
  """
  @type pixel_fun :: (x :: integer(), y :: integer() -> term())

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
    text
    |> to_charlist()
    |> Enum.reduce({tlx, tly}, fn char, {x, y} ->
      draw_char(char, x, y, font, put_pixel, opts)
    end)
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
    opts = Keyword.merge(@draw_default_opts, opts)

    size_x = opts[:size_x]

    %{size: {_, font_h}} = font

    case lookup_glyph(codepoint, font) do
      %Glyph{} = glyph ->
        draw_glyph(glyph, clx, cly + font_h, put_pixel, opts)

        glyph_dx = glyph.dwx

        {clx + glyph_dx * size_x, cly}

      _ ->
        {clx, cly}
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

  defp draw_glyph(%Glyph{} = glyph, gx, gy, put_pixel, opts) do
    opts = Keyword.merge(@draw_default_opts, opts)

    %{
      data: data,
      size: {_bb_w, bb_h},
      offset: {bb_xoff, bb_yoff}
    } = glyph

    x = gx - bb_xoff
    y = gy - bb_yoff - bb_h

    do_render_glyph(data, {x, y}, put_pixel, opts)
  end

  defp do_render_glyph(rows, pos, put_pixel, opts, iy \\ 0)

  defp do_render_glyph([], _pos, _put_pixel, _opts, _iy),
    do: nil

  defp do_render_glyph([row | rows], pos, put_pixel, opts, iy) do
    render_glyph_row(row, pos, iy, put_pixel, opts)

    do_render_glyph(rows, pos, put_pixel, opts, iy + opts[:size_y])
  end

  defp render_glyph_row(row, pos, iy, put_pixel, opts, ix \\ 0)

  defp render_glyph_row(<<>>, _pos, _iy, _put_pixel, _opts, _ix),
    do: nil

  defp render_glyph_row(<<1::1, rest::bitstring>>, {x, y} = pos, iy, put_pixel, opts, ix) do
    for ox <- 0..(opts[:size_x] - 1), oy <- 0..(opts[:size_y] - 1) do
      put_pixel.(x + ix + ox, y + iy + oy)
    end

    render_glyph_row(rest, pos, iy, put_pixel, opts, ix + opts[:size_x])
  end

  defp render_glyph_row(<<_::1, rest::bitstring>>, pos, iy, put_pixel, opts, ix),
    do: render_glyph_row(rest, pos, iy, put_pixel, opts, ix + opts[:size_x])

  defp lookup_glyph(char, font),
    do: Map.get(font.glyphs, char)
end

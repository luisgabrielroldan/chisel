defmodule Chisel.RendererTest do
  use ExUnit.Case

  setup do
    {:ok, font} = Chisel.Font.load("test/fixtures/5x8.bdf")
    {:ok, %{font: font}}
  end

  describe "reduce_draw_char/7" do
    test "draw a character", %{font: font} do
      assert test_canvas(10, 10, fn write_pixel ->
               Chisel.Renderer.reduce_draw_char(
                 36,
                 0,
                 0,
                 font,
                 [],
                 write_pixel
               )
             end) ==
               [
                 "          ",
                 "  x       ",
                 " xxx      ",
                 "x x       ",
                 " xxx      ",
                 "  x x     ",
                 " xxx      ",
                 "  x       ",
                 "          ",
                 "          "
               ]
    end
  end

  describe "reduce_draw_text/7" do
    test "draw some letters", %{font: font} do
      assert test_canvas(50, 10, fn write_pixel ->
               Chisel.Renderer.reduce_draw_text(
                 "abcdefghij",
                 0,
                 0,
                 font,
                 [],
                 write_pixel
               )
             end) ==
               [
                 "                                                  ",
                 "                                                  ",
                 "     x            x        x       x      x     x ",
                 "     x            x       x x      x              ",
                 " xxx xxx    xx  xxx  xx   x    xx  xxx   xx     x ",
                 "x  x x  x  x   x  x x xx xxx  x  x x  x   x     x ",
                 "x  x x  x  x   x  x xx    x    xxx x  x   x     x ",
                 " xxx xxx    xx  xxx  xx   x      x x  x  xxx  x x ",
                 "                               xx              x  ",
                 "                                                  "
               ]
    end

    test "draw some numbers", %{font: font} do
      assert test_canvas(50, 10, fn write_pixel ->
               Chisel.Renderer.reduce_draw_text(
                 "1234567890",
                 0,
                 0,
                 font,
                 [],
                 write_pixel
               )
             end) ==
               [
                 "                                                  ",
                 "                                                  ",
                 "  x   xx  xxxx   x  xxxx  xx  xxxx  xx   xx    x  ",
                 " xx  x  x   x   xx  x    x       x x  x x  x  x x ",
                 "  x     x  xx  x x  xxx  xxx    x   xx  x  x  x x ",
                 "  x   xx     x xxxx    x x  x   x  x  x  xxx  x x ",
                 "  x  x    x  x   x  x  x x  x  x   x  x    x  x x ",
                 " xxx xxxx  xx    x   xx   xx   x    xx   xx    x  ",
                 "                                                  ",
                 "                                                  "
               ]
    end

    test "draw some symbols", %{font: font} do
      assert test_canvas(50, 10, fn write_pixel ->
               Chisel.Renderer.reduce_draw_text(
                 "!@#-<=>+{}",
                 0,
                 0,
                 font,
                 [],
                 write_pixel
               )
             end) ==
               [
                 "                                                  ",
                 "       xx  x x                            xx xx   ",
                 "  x   x  x x x         x       x         x     x  ",
                 "  x  x  xxxxxxx       x         x    x    x   x   ",
                 "  x  x x x x x       x   xxxx    x   x  xx     xx ",
                 "  x  x x xxxxxxxxxx  x           x xxxxx  x   x   ",
                 "     x  x  x x        x  xxxx   x    x   x     x  ",
                 "  x   x    x x         x       x     x    xx xx   ",
                 "       xx                                         ",
                 "                                                  "
               ]
    end

    test "draw magnified", %{font: font} do
      assert test_canvas(16, 18, fn write_pixel ->
               Chisel.Renderer.reduce_draw_text(
                 "X",
                 0,
                 0,
                 font,
                 [],
                 write_pixel,
                 size_x: 3,
                 size_y: 2
               )
             end) ==
               [
                 "                ",
                 "                ",
                 "                ",
                 "xxx      xxx    ",
                 "xxx      xxx    ",
                 "xxx      xxx    ",
                 "xxx      xxx    ",
                 "   xxxxxx       ",
                 "   xxxxxx       ",
                 "   xxxxxx       ",
                 "   xxxxxx       ",
                 "xxx      xxx    ",
                 "xxx      xxx    ",
                 "xxx      xxx    ",
                 "xxx      xxx    ",
                 "                ",
                 "                ",
                 "                "
               ]
    end

    test "draw new lines", %{font: font} do
      assert test_canvas(20, 20, fn write_pixel ->
               Chisel.Renderer.reduce_draw_text(
                 "abcd\r\nefgh",
                 0,
                 0,
                 font,
                 [],
                 write_pixel
               )
             end) ==
               [
                 "                    ",
                 "                    ",
                 "     x            x ",
                 "     x            x ",
                 " xxx xxx    xx  xxx ",
                 "x  x x  x  x   x  x ",
                 "x  x x  x  x   x  x ",
                 " xxx xxx    xx  xxx ",
                 "                    ",
                 "                    ",
                 "       x       x    ",
                 "      x x      x    ",
                 " xx   x    xx  xxx  ",
                 "x xx xxx  x  x x  x ",
                 "xx    x    xxx x  x ",
                 " xx   x      x x  x ",
                 "           xx       ",
                 "                    ",
                 "                    ",
                 "                    "
               ]
    end
  end

  describe "draw_char/6" do
    test "draw a character", %{font: font} do
      assert test_canvas_no_reducer(10, 10, fn write_pixel ->
               Chisel.Renderer.draw_char(
                 36,
                 0,
                 0,
                 font,
                 write_pixel
               )
             end) ==
               [
                 "          ",
                 "  x       ",
                 " xxx      ",
                 "x x       ",
                 " xxx      ",
                 "  x x     ",
                 " xxx      ",
                 "  x       ",
                 "          ",
                 "          "
               ]
    end
  end

  describe "draw_text/6" do
    test "draw some letters", %{font: font} do
      assert test_canvas_no_reducer(50, 10, fn write_pixel ->
               Chisel.Renderer.draw_text(
                 "foobar1234",
                 0,
                 0,
                 font,
                 write_pixel
               )
             end) ==
               [
                 "                                                  ",
                 "                                                  ",
                 "  x            x                x   xx  xxxx   x  ",
                 " x x           x               xx  x  x   x   xx  ",
                 " x    xx   xx  xxx   xxx x x    x     x  xx  x x  ",
                 "xxx  x  x x  x x  x x  x xx x   x   xx     x xxxx ",
                 " x   x  x x  x x  x x  x x      x  x    x  x   x  ",
                 " x    xx   xx  xxx   xxx x     xxx xxxx  xx    x  ",
                 "                                                  ",
                 "                                                  "
               ]
    end
  end

  describe "get_text_width/3" do
    test "normal horizontal size", %{font: font} do
      assert Chisel.Renderer.get_text_width("abcd", font) == 20
      assert Chisel.Renderer.get_text_width("abcd", font, size_y: 2) == 20
    end

    test "size x2", %{font: font} do
      assert Chisel.Renderer.get_text_width("abcd", font, size_x: 2) == 40
    end
  end

  def test_canvas(w, h, fun) do
    put_pixel = fn x, y, pixels ->
      [{x, y} | pixels]
    end

    {res, _, _} = fun.(put_pixel)

    for y <- 0..(h - 1) do
      for x <- 0..(w - 1) do
        if Enum.member?(res, {x, y}) do
          "x"
        else
          " "
        end
      end
      |> to_string()
    end
  end

  def test_canvas_no_reducer(w, h, fun) do
    {:ok, agent} = Agent.start_link(fn -> [] end)

    put_pixel = fn x, y ->
      Agent.update(agent, fn pixels ->
        [{x, y} | pixels]
      end)
    end

    fun.(put_pixel)

    res = Agent.get(agent, & &1)

    Agent.stop(agent)

    for y <- 0..(h - 1) do
      for x <- 0..(w - 1) do
        if Enum.member?(res, {x, y}) do
          "x"
        else
          " "
        end
      end
      |> to_string()
    end
  end
end

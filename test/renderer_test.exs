defmodule Chisel.RendererTest do
  use ExUnit.Case

  setup do
    {:ok, font} = Chisel.Font.load("test/fixtures/c64.bdf")
    {:ok, %{font: font}}
  end

  describe "draw_char/6" do
    test "draw a character", %{font: font} do
      assert with_canvas(10, 10, fn write_pixel ->
               Chisel.Renderer.draw_char(
                 36,
                 0,
                 0,
                 font,
                 write_pixel
               )
             end) ==
               [
                 "           ",
                 "           ",
                 "   xx      ",
                 "  xxxxx    ",
                 " xx        ",
                 "  xxxx     ",
                 "     xx    ",
                 " xxxxx     ",
                 "   xx      ",
                 "           ",
                 "           "
               ]
    end
  end

  describe "draw_text/6" do
    test "draw some letters", %{font: font} do
      assert with_canvas(80, 10, fn write_pixel ->
               Chisel.Renderer.draw_text(
                 "abcdefghij",
                 0,
                 0,
                 font,
                 write_pixel
               )
             end) == [
               "                                                                                 ",
               "                                                                                 ",
               "                                                                                 ",
               "         xx                  xx             xxx          xx        xx        xx  ",
               "  xxxx   xx       xxxx       xx   xxxx     xx     xxxxx  xx                      ",
               "     xx  xxxxx   xx       xxxxx  xx  xx   xxxxx  xx  xx  xxxxx    xxx        xx  ",
               "  xxxxx  xx  xx  xx      xx  xx  xxxxxx    xx    xx  xx  xx  xx    xx        xx  ",
               " xx  xx  xx  xx  xx      xx  xx  xx        xx     xxxxx  xx  xx    xx        xx  ",
               "  xxxxx  xxxxx    xxxx    xxxxx   xxxx     xx        xx  xx  xx   xxxx       xx  ",
               "                                                 xxxxx                    xxxx   ",
               "                                                                                 "
             ]
    end

    test "draw some numbers", %{font: font} do
      assert with_canvas(80, 10, fn write_pixel ->
               Chisel.Renderer.draw_text(
                 "1234567890",
                 0,
                 0,
                 font,
                 write_pixel
               )
             end) ==
               [
                 "                                                                                 ",
                 "                                                                                 ",
                 "   xx     xxxx    xxxx       xx  xxxxxx   xxxx   xxxxxx   xxxx    xxxx    xxxx   ",
                 "   xx    xx  xx  xx  xx     xxx  xx      xx  xx  xx  xx  xx  xx  xx  xx  xx  xx  ",
                 "  xxx        xx      xx    xxxx  xxxxx   xx         xx   xx  xx  xx  xx  xx xxx  ",
                 "   xx       xx     xxx   xx  xx      xx  xxxxx     xx     xxxx    xxxxx  xxx xx  ",
                 "   xx     xx         xx  xxxxxxx     xx  xx  xx    xx    xx  xx      xx  xx  xx  ",
                 "   xx    xx      xx  xx      xx  xx  xx  xx  xx    xx    xx  xx  xx  xx  xx  xx  ",
                 " xxxxxx  xxxxxx   xxxx       xx   xxxx    xxxx     xx     xxxx    xxxx    xxxx   ",
                 "                                                                                 ",
                 "                                                                                 "
               ]
    end

    test "draw some symbols", %{font: font} do
      assert with_canvas(80, 10, fn write_pixel ->
               Chisel.Renderer.draw_text(
                 "!@#-<=>+{}",
                 0,
                 0,
                 font,
                 write_pixel
               )
             end) == [
               "                                                                                 ",
               "                                                                                 ",
               "   xx     xxxx   xx  xx             xxx          xxx               xxx    xxx    ",
               "   xx    xx  xx  xx  xx            xx              xx      xx     xx        xx   ",
               "   xx    xx xxx xxxxxxxx          xx     xxxxxx     xx     xx     xx        xx   ",
               "   xx    xx xxx  xx  xx  xxxxxx  xx                  xx  xxxxxx  xx          xx  ",
               "         xx     xxxxxxxx          xx     xxxxxx     xx     xx     xx        xx   ",
               "         xx   x  xx  xx            xx              xx      xx     xx        xx   ",
               "   xx     xxxx   xx  xx             xxx          xxx               xxx    xxx    ",
               "                                                                                 ",
               "                                                                                 "
             ]
    end

    test "draw magnified", %{font: font} do
      assert with_canvas(16, 18, fn write_pixel ->
               Chisel.Renderer.draw_text(
                 "X",
                 0,
                 0,
                 font,
                 write_pixel,
                 size_x: 2,
                 size_y: 2
               )
             end) == [
               "                 ",
               "                 ",
               "  xxxx    xxxx   ",
               "  xxxx    xxxx   ",
               "  xxxx    xxxx   ",
               "  xxxx    xxxx   ",
               "    xxxxxxxx     ",
               "    xxxxxxxx     ",
               "      xxxx       ",
               "      xxxx       ",
               "    xxxxxxxx     ",
               "    xxxxxxxx     ",
               "  xxxx    xxxx   ",
               "  xxxx    xxxx   ",
               "  xxxx    xxxx   ",
               "  xxxx    xxxx   ",
               "                 ",
               "                 ",
               "                 "
             ]
    end

    test "draw new lines", %{font: font} do
      assert with_canvas(40, 20, fn write_pixel ->
               Chisel.Renderer.draw_text(
                 "abcd\r\nefgh",
                 0,
                 0,
                 font,
                 write_pixel
               )
             end) == [
               "                                         ",
               "                                         ",
               "                                         ",
               "         xx                  xx          ",
               "  xxxx   xx       xxxx       xx          ",
               "     xx  xxxxx   xx       xxxxx          ",
               "  xxxxx  xx  xx  xx      xx  xx          ",
               " xx  xx  xx  xx  xx      xx  xx          ",
               "  xxxxx  xxxxx    xxxx    xxxxx          ",
               "                                         ",
               "                                         ",
               "            xxx          xx              ",
               "  xxxx     xx     xxxxx  xx              ",
               " xx  xx   xxxxx  xx  xx  xxxxx           ",
               " xxxxxx    xx    xx  xx  xx  xx          ",
               " xx        xx     xxxxx  xx  xx          ",
               "  xxxx     xx        xx  xx  xx          ",
               "                 xxxxx                   ",
               "                                         ",
               "                                         ",
               "                                         "
             ]
    end
  end

  describe "get_text_width/3" do
    test "normal horizontal size", %{font: font} do
      assert Chisel.Renderer.get_text_width("abcd", font) == 32
      assert Chisel.Renderer.get_text_width("abcd", font, size_y: 2) == 32
    end

    test "size x2", %{font: font} do
      assert Chisel.Renderer.get_text_width("abcd", font, size_x: 2) == 64
    end
  end

  def with_canvas(w, h, fun) do
    {:ok, agent} = Agent.start_link(fn -> [] end)

    put_pixel = fn x, y ->
      Agent.update(agent, fn pixels ->
        [{x, y} | pixels]
      end)
    end

    fun.(put_pixel)

    res = Agent.get(agent, & &1)

    Agent.stop(agent)

    for y <- 0..h do
      for x <- 0..w do
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

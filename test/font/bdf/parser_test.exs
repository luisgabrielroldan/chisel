defmodule Chisel.Font.BDF.ParserTest do
  use ExUnit.Case

  alias Chisel.Font
  alias Chisel.Font.BDF.Parser

  @tokens [
    {:keyword, "STARTFONT", {1, 10}},
    {:value, "2.1", {1, 14}},
    {:eol, ~c"\n", {1, 14}},
    {:keyword, "COMMENT", {2, 8}},
    {:value, "Lorem", {2, 14}},
    {:value, "ipsum", {2, 20}},
    {:value, "dolor", {2, 26}},
    {:value, "set", {2, 30}},
    {:eol, ~c"\n", {2, 30}},
    {:keyword, "FONT", {3, 5}},
    {:value, "simple_font", {3, 17}},
    {:eol, ~c"\n", {3, 17}},
    {:keyword, "SIZE", {4, 5}},
    {:value, "8", {4, 7}},
    {:value, "72", {4, 10}},
    {:value, "72", {4, 13}},
    {:eol, ~c"\n", {4, 13}},
    {:eol, ~c"\n", {5, 1}},
    {:keyword, "CHARS", {6, 6}},
    {:value, "2", {6, 8}},
    {:eol, ~c"\n", {6, 8}},
    {:keyword, "STARTCHAR", {7, 10}},
    {:value, "C1", {7, 13}},
    {:eol, ~c"\n", {7, 13}},
    {:keyword, "ENCODING", {8, 9}},
    {:value, "128", {8, 13}},
    {:eol, ~c"\n", {8, 13}},
    {:keyword, "DWIDTH", {9, 7}},
    {:value, "8", {9, 9}},
    {:value, "0", {9, 11}},
    {:eol, ~c"\n", {9, 11}},
    {:keyword, "BBX", {10, 4}},
    {:value, "2", {10, 6}},
    {:value, "8", {10, 8}},
    {:value, "3", {10, 10}},
    {:value, "0", {10, 12}},
    {:eol, ~c"\n", {10, 12}},
    {:keyword, "BITMAP", {11, 7}},
    {:eol, ~c"\n", {11, 7}},
    {:value, "FF", {12, 3}},
    {:eol, ~c"\n", {12, 3}},
    {:value, "FF", {13, 3}},
    {:eol, ~c"\n", {13, 3}},
    {:value, "FF", {14, 3}},
    {:eol, ~c"\n", {14, 3}},
    {:value, "FF", {15, 3}},
    {:eol, ~c"\n", {15, 3}},
    {:value, "FF", {16, 3}},
    {:eol, ~c"\n", {16, 3}},
    {:value, "FF", {17, 3}},
    {:eol, ~c"\n", {17, 3}},
    {:value, "FF", {18, 3}},
    {:eol, ~c"\n", {18, 3}},
    {:value, "FF", {19, 3}},
    {:eol, ~c"\n", {19, 3}},
    {:keyword, "ENDCHAR", {20, 8}},
    {:eol, ~c"\n", {20, 8}},
    {:eol, ~c"\n", {21, 1}},
    {:keyword, "STARTCHAR", {22, 10}},
    {:value, "C2", {22, 13}},
    {:eol, ~c"\n", {22, 13}},
    {:keyword, "ENCODING", {23, 9}},
    {:value, "129", {23, 13}},
    {:eol, ~c"\n", {23, 13}},
    {:keyword, "DWIDTH", {24, 7}},
    {:value, "8", {24, 9}},
    {:value, "0", {24, 11}},
    {:eol, ~c"\n", {24, 11}},
    {:keyword, "BBX", {25, 4}},
    {:value, "8", {25, 6}},
    {:value, "2", {25, 8}},
    {:value, "0", {25, 10}},
    {:value, "3", {25, 12}},
    {:eol, ~c"\n", {25, 12}},
    {:keyword, "BITMAP", {26, 7}},
    {:eol, ~c"\n", {26, 7}},
    {:value, "FF", {27, 3}},
    {:eol, ~c"\n", {27, 3}},
    {:value, "FF", {28, 3}},
    {:eol, ~c"\n", {28, 3}},
    {:keyword, "ENDCHAR", {29, 8}},
    {:eol, ~c"\n", {29, 8}},
    {:keyword, "ENDFONT", {30, 8}},
    {:eol, ~c"\n", {30, 8}}
  ]

  test "parse!/1" do
    assert {:ok, font} = Parser.parse!(@tokens)

    assert %Font{
             glyphs: %{
               128 => %Font.Glyph{
                 codepoint: 128,
                 data: <<255, 255>>,
                 dwx: 8,
                 name: "C1",
                 offset: {3, 0},
                 size: {2, 8}
               },
               129 => %Font.Glyph{
                 codepoint: 129,
                 data: <<255, 255>>,
                 dwx: 8,
                 name: "C2",
                 offset: {0, 3},
                 size: {8, 2}
               }
             },
             name: "simple_font",
             offset: {0, 0},
             size: {8, 8}
           } = font
  end
end

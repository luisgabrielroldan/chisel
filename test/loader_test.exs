defmodule Chisel.Font.LoaderTest do
  use ExUnit.Case

  alias Chisel.Font
  alias Chisel.Font.Loader

  test "load_font/1" do
    assert {:ok, %Font{}} = Loader.load_font("test/fixtures/m2icon_9.bdf")
    assert {:ok, %Font{}} = Loader.load_font("test/fixtures/u8glib_4.bdf")
    assert {:ok, %Font{}} = Loader.load_font("test/fixtures/uncomplete.bdf")
  end
end

defmodule Chisel.Font.LoaderTest do
  use ExUnit.Case

  alias Chisel.Font
  alias Chisel.Font.Loader

  test "load_font/1" do
    assert {:ok, %Font{}} = Loader.load_font("test/fixtures/c64.bdf")
    assert {:ok, %Font{}} = Loader.load_font("test/fixtures/uncomplete.bdf")
    assert {:ok, %Font{}} = Loader.load_font("test/fixtures/unifont.bdf")
  end
end

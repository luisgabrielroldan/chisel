defmodule Chisel.Font do
  @moduledoc """
  Font
  """

  alias Chisel.Font
  alias Font.Glyph

  @type t :: %__MODULE__{
          name: String.t(),
          glyphs: %{Glyph.codepoint() => Glyph.t()},
          size: {w :: integer(), h :: integer()},
          offset: {x :: integer(), y :: integer()}
        }

  @type load_opts ::
          list(
            {:encoding,
             :latin1
             | :unicode
             | :utf8
             | :utf16
             | :utf32
             | {:utf16, :big | :little}
             | {:utf32, :big | :little}}
          )

  defstruct name: nil,
            glyphs: nil,
            size: nil,
            offset: nil

  @doc """
  Loads a font from a file
  """
  @spec load(filename :: String.t(), opts :: load_opts()) :: {:ok, Font.t()} | {:error, term()}
  defdelegate load(filename, opts \\ []), to: Chisel.Font.Loader, as: :load_font

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(font, _opts) do
      concat(["#Font<#{font.name}>"])
    end
  end
end

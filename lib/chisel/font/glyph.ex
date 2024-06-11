defmodule Chisel.Font.Glyph do
  @moduledoc """
  Defines a glyph for font rendering, including its properties and bitmap data. Useful for managing glyph rendering in graphics applications.

  ## Attributes
  - `name`: Identifies the glyph.
  - `codepoint`: Unicode codepoint of the glyph.
  - `dwx`: Horizontal drawing width.
  - `size`: Width and height of the glyph.
  - `offset`: Position offset from the baseline.
  - `data`: Bitmap data of the glyph.
  """

  @type codepoint :: integer()
  @type data :: list(binary())

  @type t :: %__MODULE__{
          name: String.t(),
          codepoint: codepoint(),
          dwx: integer(),
          size: {w :: integer(), h :: integer()},
          offset: {x :: integer(), y :: integer()},
          data: data()
        }

  defstruct name: nil,
            codepoint: nil,
            dwx: nil,
            size: nil,
            offset: nil,
            data: nil
end

defmodule Chisel.Font.Glyph do
  @moduledoc """
  Represents an element of writing.
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

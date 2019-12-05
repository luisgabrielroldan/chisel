defmodule Chisel.Font.Glyph do
  @moduledoc false

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

defmodule Chisel.Font.BDF do
  @moduledoc false

  alias Chisel.Font.BDF.{Lexer, Parser}

  def load_file!(filename, opts \\ []) do
    encoding = Keyword.get(opts, :encoding, :utf8)

    filename
    |> File.stream!([
      {:read_ahead, 1024},
      {:encoding, encoding}
    ])
    |> Lexer.scan!()
    |> Parser.parse!()
  end
end

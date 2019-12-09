defmodule Chisel.Font.Loader do
  @moduledoc false
  alias Chisel.Font.BDF

  def load_font(filename, opts \\ []) do
    try do
      load_file!(filename, Path.extname(filename), opts)
    catch
      {:error, _} = error ->
        error

      err ->
        {:error, err}
    rescue
      err in File.Error ->
        {:error, err.reason}
    end
  end

  defp load_file!(filename, ".bdf", opts),
    do: BDF.load_file!(filename, opts)

  defp load_file!(_filename, _ext, _opts),
    do: {:error, :unknwon_format}
end

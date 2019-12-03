defmodule Chisel.MixProject do
  use Mix.Project

  def project do
    [
      app: :chisel,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:egd, git: "https://github.com/erlang/egd", tag: "0.10.0", only: [:test]},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}
    ]
  end
end

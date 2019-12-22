defmodule Chisel.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :chisel,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      docs: docs(),
      package: package(),
      source_url: "https://github.com/luisgabrielroldan/chisel",
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

  defp description do
    """
    Chisel is a library that uses bitmap fonts to sculpt text on any device that can handle pixels.
    """
  end

  defp package do
    %{
      files: ["lib", "mix.exs", "README.md"],
      maintainers: [
        "Gabriel Roldan"
      ],
      licenses: ["Apache License 2.0"],
      links: %{
        "GitHub" => "https://github.com/luisgabrielroldan/chisel"
      }
    }
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/luisgabrielroldan/chisel",
      extras: [
        "README.md"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:earmark, "~> 1.3", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [docs: ["docs", &copy_images/1]]
  end

  defp copy_images(_) do
    File.cp_r!("images/", "doc/images/")
  end
end

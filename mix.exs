defmodule Brainfuck.MixProject do
  use Mix.Project

  def project do
    [
      app: :brainfuck,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      config_path: "./config/config.exs"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Brainfuck.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:table_rex, "~> 3.1.1"},
      {:jason, "~> 1.2"}
    ]
  end
end

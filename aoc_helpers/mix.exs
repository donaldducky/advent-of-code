defmodule AocHelpers.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc_helpers,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:req, "~> 0.5.8"},
      {:kino, "~> 0.14.2"},
      {:libgraph, "~> 0.16.0"}
    ]
  end
end

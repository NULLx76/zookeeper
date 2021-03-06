defmodule Zookeeper.MixProject do
  use Mix.Project

  def project do
    [
      app: :zookeeper,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug_cowboy, :poison, :peerage],
      mod: {Zookeeper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.5.2"},
      {:poison, "~> 5.0"},
      {:enacl, "~> 1.2.1"},
      {:castore, "~> 0.1"},
      {:finch, "~> 0.9"},
      {:ex_const, "~> 0.2"},
      {:peerage, "~> 1.0"},
    ]
  end
end

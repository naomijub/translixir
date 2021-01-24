defmodule Translixir.MixProject do
  use Mix.Project

  @source_url "https://github.com/naomijub/translixir/"

  def project do
    [
      app: :translixir,
      version: "0.4.0",
      description: "Crux Datalog DB Client",
      elixir: "~> 1.11.1",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: applications(Mix.env()),
      mod: {Translixir.Application, []}
    ]
  end

  defp applications(:test), do: applications(:default) ++ [:mox]
  defp applications(_), do: [:logger, :httpoison, :eden]

  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:timex, "~> 3.5"},
      {:credo, "~> 1.5.0", only: [:dev, :test, :ci], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:eden, "~> 2.1.0"},
      {:recase, "~> 0.5"},
      {:mox, "~> 1.0.0", only: :test},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs .formatter.exs README* LICENSE* CHANGELOG*),
      contributors: ["Julia Naomi"],
      licenses: ["LGPL-3.0"],
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url,
        "Crux" => "https://www.opencrux.com/reference/installation.html#restapi"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "CHANGELOG.md",
        "README.md",
        "LICENSE"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]
end

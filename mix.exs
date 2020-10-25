defmodule Translixir.MixProject do
  use Mix.Project

  @source_url "https://github.com/naomijub/translixir/"

  def project do
    [
      app: :translixir,
      version: "0.3.0",
      description: "Crux Datalog DB Client",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :httpoison, :eden],
      mod: {Translixir.Application, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:timex, "~> 3.5"},
      {:credo, "~> 1.4.1", only: [:dev, :test, :ci], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:eden, git: "git://github.com/jfacorro/Eden.git"},
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
end

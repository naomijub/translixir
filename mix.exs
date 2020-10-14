defmodule Translixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :translixir_application,
      version: "0.1.0",
      description: "Crux Datalog DB Client",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      package: package,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {Translixir.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     contributors: ["Julia Naomi"],
     licenses: ["LGPL-3.0"],
     links: %{"GitHub" => "https://github.com/naomijub/translixir/",
              "Crux" => "https://www.opencrux.com/reference/installation.html#restapi"}]
  end
end

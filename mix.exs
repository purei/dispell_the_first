defmodule Dispell.Mixfile do
  use Mix.Project

  def project do
    [
      app: :dispell,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Dispell.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:alchemy, "~> 0.6.0", hex: :discord_alchemy}, # Discord
      {:amnesia, github: "meh/amnesia", tag: :master}, # custom commands DB
      {:poison, "~> 3.1"},
      {:spellstone_xml, path: "../spellstone_xml"},
      {:logger_file_backend, "0.0.10"}
    ]
  end
end

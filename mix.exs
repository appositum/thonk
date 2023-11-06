defmodule Thonk.MixProject do
  use Mix.Project

  def project do
    [
      app: :thonk,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Thonk, []}
    ]
  end

  defp deps do
    [
      {:alchemy, "~> 0.6.0", hex: :discord_alchemy},
      {:floki, "~> 0.20.0"},
    ]
  end
end

defmodule Tigela.MixProject do
  use Mix.Project

  def project do
    [
      app: :tigela,
      version: "0.1.0",
      elixir: "~> 1.16",
      escript: [main_module: Tigela],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end

defmodule PythonEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :python_ex,
      version: "0.3.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end

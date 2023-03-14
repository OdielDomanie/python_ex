defmodule PythonEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :python_ex,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers() ++ [:python]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Python, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4", runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end

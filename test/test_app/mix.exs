defmodule TestProj.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_proj,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: Mix.compilers() ++ [:python],
      python_bin: "python3.10",
      pip_deps: pip_deps()
    ]
  end

  def application do
    [
      mod: {TestApp, []}
    ]
  end

  defp deps do
    [
      {:python_ex, path: "../.."}
    ]
  end

  defp pip_deps do
    [
      "yt-dlp==2023.3.4",
      "numpy"
    ]
  end
end
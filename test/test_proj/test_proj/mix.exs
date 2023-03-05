defmodule TestProj.MixProject do
  use Mix.Project

  def project do
    [
      app: :test_proj,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
      python_bin: "python3.10"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:python_ex, path: "..\.."}
      {:"yt-dlp", compile: "mix python_ex.pip yt-dlp==2023.3.4"},
      {:"numpy", compile: "mix python_ex.pip numpy"}
    ]
  end
end

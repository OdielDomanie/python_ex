defmodule Mix.Tasks.Compile.Python do
  @moduledoc """
  Create a Python venv and install dependencies via pip.
  `mix.exs` should have two more keys
  `:python_bin` and `:pip_deps`.
  """

  use Mix.Task.Compiler

  @venv_dir Path.join(Mix.Project.app_path(), "venv")
  @python Path.join(@venv_dir, "bin/python")
  @manifest Path.join(@venv_dir, "python_from")

  # Compiler must return {:ok | :noop | :error, [diagnostic]}
  def run(_args) do
    python_bin = Keyword.fetch!(Mix.Project.config(), :python_bin)

    if File.exists?(@python) || ({:ok, ^python_bin} = File.read(@manifest)) do
      {:noop, []}
    else
      do_compile()
    end
  end

  defp do_compile() do
    config = Mix.Project.config()

    _ = clean()

    with {_, 0} <-
           config
           |> Keyword.fetch!(:python_bin)
           |> System.cmd(["-m", "venv", @venv_dir], stderr_to_stdout: true),
         {_, 0} <-
           System.cmd(
             @python,
             ["-m", "pip", "install", "-y", "-U" | Keyword.fetch!(config, :pip_deps)],
             stderr_to_stdout: true
           ) do
      {:ok, []}
    else
      {out, ret} ->
        {:error,
         [
           %Mix.Task.Compiler.Diagnostic{
             compiler_name: "Python",
             details: ret,
             file: Mix.Project.project_file(),
             message: inspect(out),
             position: 0,
             severity: :error
           }
         ]}
    end
  end

  def manifests, do: [@manifest]

  def clean() do
    File.rmdir(@venv_dir)
  end
end

defmodule Mix.Tasks.Compile.Python do
  @moduledoc """
  Create a Python venv and install dependencies via pip.
  pip depencies are declared in `python_depencies/0` in `mix.exs`.
  """

  use Mix.Task.Compiler

  @venv_dir Path.join(Mix.Project.app_path(), "venv")

  # Compiler must return {:ok | :noop | :error, [diagnostic]}
  # TODO: return better
  def run(_args) do
    config = Mix.Project.config()

    with {_, 0} <-
           config
           |> Keyword.fetch!(:python_bin)
           |> System.cmd(["-m", "venv", @venv_dir], stderr_to_stdout: true),
         python = Path.join(@venv_dir, "bin/python"),
         {_, 0} <-
           System.cmd(
             python,
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
             file: __ENV__.file,
             message: inspect(out),
             position: 0,
             severity: :error
           }
         ]}
    end
  end

  def clean do
    File.rmdir(@venv_dir)
  end
end

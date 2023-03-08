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

  def python_path, do: @python

  # Compiler must return {:ok | :noop | :error, [diagnostic]}
  def run(_args) do
    python_bin = Keyword.fetch!(Mix.Project.config(), :python_bin)

    if File.exists?(@python) && {:ok, python_bin} == File.read(@manifest) do
      {:noop, []}
    else
      do_compile()
      File.write(@manifest, python_bin)
    end
  end

  defp do_compile() do
    config = Mix.Project.config()
    python_bin = Keyword.fetch!(config, :python_bin)

    _ = clean()

    with {_, 0} <- System.cmd(python_bin, ["-m", "venv", @venv_dir], stderr_to_stdout: true),
         {_, 0} <- install_pip_pckgs(config) do
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

  defp install_pip_pckgs(config) do
    case Keyword.get(config, :pip_deps) do
      nil ->
        {"", 0}

      deps when is_list(deps) ->
        System.cmd(
          @python,
          ["-m", "pip", "install", "-y", "-U", "pip", "wheel", "setuptools"],
          stderr_to_stdout: true
        )

        System.cmd(
          @python,
          ["-m", "pip", "install", "-y", "-U" | Keyword.fetch!(config, :pip_deps)],
          stderr_to_stdout: true
        )
    end
  end

  def manifests, do: [@manifest]

  def clean() do
    File.rmdir(@venv_dir)
  end
end

defmodule Mix.Tasks.Compile.Python do
  @moduledoc false

  use Mix.Task.Compiler

  def venv_dir, do: Path.join(Mix.Project.build_path(), "venv")
  def python, do: Path.join(venv_dir(), "bin/python")
  defp manifest, do: Path.join(venv_dir(), "python_from")
  def python_bin, do: System.get_env("PYTHON", "python") |> System.find_executable()

  # Compiler must return {:ok | :noop | :error, [diagnostic]}
  def run(_args) do
    create_or_skip_venv()
  end

  defp create_or_skip_venv() do
    if venv_uptodate?() do
      {:noop, []}
    else
      _ = clean()
      create_venv()
    end
  end

  defp venv_uptodate?() do
    File.exists?(python()) and {:ok, python_bin()} == File.read(manifest())
  end

  defp create_venv() do
    case System.cmd(python_bin(), ["-m", "venv", venv_dir()], stderr_to_stdout: true) do
      {_, 0} ->
        :ok = File.write(manifest(), python_bin())
        {:ok, []}

      {out, ret} ->
        errdiag_from_cmd({out, ret})
    end
  end

  defp errdiag_from_cmd({out, ret}) do
    {:error,
     [
       %Mix.Task.Compiler.Diagnostic{
         compiler_name: "Python",
         details: inspect(out),
         file: Mix.Project.project_file(),
         message: "venv returns #{ret}",
         position: 0,
         severity: :error
       }
     ]}
  end

  def manifests, do: [manifest()]

  def clean() do
    File.rmdir(venv_dir())
  end
end

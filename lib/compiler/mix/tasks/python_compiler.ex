defmodule Mix.Tasks.Compile.Python do
  @moduledoc """
  Create a Python venv and install dependencies via pip.
  `mix.exs` should have two more keys
  `:python_bin` and `:pip_deps`.
  """

  use Mix.Task.Compiler

  @venv_dir Path.join(Mix.Project.build_path(), "venv")
  Mix.Project.app_path()
  @python Path.join(@venv_dir, "bin/python")
  @manifest Path.join(@venv_dir, "python_from")
  @python_bin System.get_env("PYTHON", "python") |> System.find_executable()

  def python_path, do: @python

  # Compiler must return {:ok | :noop | :error, [diagnostic]}
  def run(_args) do
    with {ok_venv, diag} when ok_venv == :ok or ok_venv == :noop <- create_or_skip_venv(),
         {ok_pip, diag_pip} = pip_install(),
         {ok_pip, diag} when ok_pip == :ok or ok_pip == :noop <- {ok_pip, diag_pip ++ diag} do
      ok = if ok_venv == :noop and ok_pip == :noop, do: :noop, else: :ok
      {ok, diag}
    else
      {:error, diag} -> {:error, diag}
    end
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
    File.exists?(@python) and {:ok, @python_bin} == File.read(@manifest)
  end

  defp create_venv() do
    case System.cmd(@python_bin, ["-m", "venv", @venv_dir], stderr_to_stdout: true) do
      {_, 0} ->
        :ok = File.write(@manifest, @python_bin)
        {:ok, []}

      {out, ret} ->
        errdiag_from_cmd({out, ret})
    end
  end

  defp pip_install() do
    case Mix.Project.config() |> Keyword.get(:pip_deps) do
      nil ->
        {:noop, []}

      deps when is_list(deps) ->
        _ =
          System.cmd(
            @python,
            ["-m", "pip", "install", "-U", "pip", "wheel", "setuptools"]
          )

        pip_install_deps()
    end
  end

  defp pip_install_deps() do
    {out, ret} =
      System.cmd(
        @python,
        [
          "-m",
          "pip",
          "install",
          "--quiet",
          "--report",
          "-",
          "-U"
          | Mix.Project.config() |> Keyword.fetch!(:pip_deps)
        ],
        stderr_to_stdout: true
      )

    case {out, ret} do
      {out_json, 0} ->
        new_installs?(out_json)

      {out, ret} ->
        errdiag_from_cmd({out, ret})
    end
  end

  defp new_installs?(json) do
    %{
      "version" => "1",
      "install" => installs
    } = Jason.decode!(json)

    if installs == [] do
      {:noop, []}
    else
      {:ok, []}
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

  def manifests, do: [@manifest]

  def clean() do
    File.rmdir(@venv_dir)
  end
end

defmodule Mix.Tasks.PythonSetup do
  @moduledoc """
  Sets up Python venv and pip packages.

  This task sets up a Python virtual environment,
  and installs packages via pip.

  The python executable can be specified as the cli arg,
  or defaults to shell's `python3`.

  Pip packages are defined as `pip_deps` in the mix project configuration.
  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    # Get the python path
    python =
      List.first(args) ||
        System.find_executable("python3")

    # Target virtual environment, which is the _build dir
    venv_dir = Path.join(Mix.Project.build_path(), "venv")
    pip_pckgs = Mix.Project.config() |> Keyword.get(:pip_deps)

    install(python, venv_dir, pip_pckgs)
  end

  @doc false
  # Create venv, install pip packages.
  def install(system_python, venv_dir, pip_pckgs) do
    with {_, 0} <- install_venv(system_python, venv_dir),
         :ok <- install_pip_pckgs(venv_dir, pip_pckgs) do
      :ok
    else
      {out, _ret} ->
        Mix.shell().error(out)
    end
  end

  @doc """
  Set up venv.
  """
  @spec install_venv(binary, binary) :: {binary, integer}
  def install_venv(system_python, venv_dir) do
    System.cmd(
      system_python,
      ["-m", "venv", venv_dir],
      stderr_to_stdout: true
    )
  end

  @doc """
  Install pip packages into the venv.

  `pip_pckgs` is directly given to `pip install` as the arguments.
  """
  @spec install_pip_pckgs(binary, [binary]) :: :ok | {binary, integer}
  def install_pip_pckgs(venv_dir, pip_pckgs) do
    case pip_pckgs do
      nil ->
        :ok

      [] ->
        :ok

      pip_deps ->
        # Install base pip packages,
        # then the specified ones,
        with {_, 0} <-
               do_pip_install(venv_dir, ["pip", "wheel", "setuptools"]),
             {_, 0} <- do_pip_install(venv_dir, pip_deps) do
          :ok
        end
    end
  end

  defp do_pip_install(venv_dir, pckgs) do
    System.cmd(
      python_path(venv_dir),
      [
        "-m",
        "pip",
        "install",
        #  "--quiet",
        "--upgrade"
        | pckgs
      ]
    )
  end

  def python_path(venv_dir), do: Path.join(venv_dir, "bin/python")
end

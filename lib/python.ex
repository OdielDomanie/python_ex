defmodule Python do
  @moduledoc """
  Documentation for `PythonEx`.
  """

  @spec install_pip_pckgs(binary, [binary]) :: :ok | {:error, binary}
  def install_pip_pckgs(python_path, pckgs) do
    case pckgs do
      [] ->
        :ok

      pip_deps ->
        # Install base pip packages,
        # then the specified ones,
        with {_, 0} <-
               do_pip_install(python_path, ["pip", "wheel", "setuptools"]),
             {_, 0} <- do_pip_install(python_path, pip_deps) do
          :ok
        else
          {stdout, _ret} -> {:error, stdout}
        end
    end
  end

  defp do_pip_install(python_path, pckgs) do
    System.cmd(
      python_path,
      [
        "-m",
        "pip",
        "install",
        #  "--quiet",
        "--upgrade"
        | pckgs
      ],
      stderr_to_stdout: true
    )
  end

  def python_path(venv_dir), do: Path.join(venv_dir, "bin/python")

  @spec install_venv(binary, binary) :: {:ok, binary} | {:error, binary}
  def install_venv(venv_path, source_python \\ "python") do
    source_python = System.find_executable(source_python)

    System.cmd(
      source_python,
      ["-m", "venv", venv_path],
      stderr_to_stdout: true
    )
    |> case do
      {_, 0} -> {:ok, python_path(venv_path)}
      {stdout, _ret} -> {:error, stdout}
    end
  end

  @spec apply(
          binary(),
          atom(),
          atom(),
          binary(),
          GenServer.server(),
          keyword()
        ) ::
          binary()
  @doc """
  Run a python function in `path/module`.
  Takes a single `binary` argument that is passed to the python
  function `(bytes) -> bytes`.

  `queue_timeout` is the timeout for this `apply/6` function.

  `py_timeout` is per the call to the Python function.
  """
  def apply(
        path,
        module,
        fun,
        arg,
        python_server,
        opts \\ [
          queue_timeout: :infinity,
          py_timeout: 5000
        ]
      ) do
    queue_timeout = Keyword.get(opts, :queue_timeout, :infinity)
    py_timeout = Keyword.get(opts, :py_timeout, 5000)

    GenServer.call(
      python_server,
      {
        :apply,
        {path, module, fun, arg, py_timeout}
      },
      queue_timeout
    )
  end
end

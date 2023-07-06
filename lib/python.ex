defmodule Python do
  @moduledoc """
  Documentation for `PythonEx`.
  """
  alias Mix.Tasks.PythonSetup

  use Application

  @impl true
  @spec start(Application.start_type(), [opt]) ::
          {:ok, pid} | {:error, term}
        when opt:
               {:pip_pckgs, [binary] | nil}
               | {:system_python_path, binary}
               | {:venv_path, binary}
               | {:python_server_name, atom}
  def start(_, args) do
    install(args)

    venv_path = args[:venv_path]
    python_server_name = args[:python_server_name] || Python.Server

    children = [
      Supervisor.child_spec({python_server_name, [venv_dir: venv_path]},
        restart: :permanent
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_all)
  end

  @spec install([opt]) ::
          :ok | {:error, {output :: Collectable.t(), ret_code :: integer}}
        when opt:
               {:pip_pckgs, [binary]}
               | {:system_python_path, binary}
               | {:venv_path, binary}
  def install(opts) do
    system_python =
      opts[:system_python_path] ||
        System.find_executable("python3")

    pip_pckgs = opts[:pip_pckgs]
    venv_path = opts[:venv_path]

    with {_, 0} <- PythonSetup.install_venv(system_python, venv_path),
         :ok <- PythonSetup.install_pip_pckgs(venv_path, pip_pckgs) do
      :ok
    else
      {_output, _ret_code} = err ->
        {:error, err}
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
        python_server \\ Python.Server,
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

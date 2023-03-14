defmodule Python do
  @moduledoc """
  Documentation for `PythonEx`.
  """
  use Application

  @impl true
  def start(_, _) do
    children = [
      Supervisor.child_spec(Python.Server, restart: :permanent)
    ]

    Supervisor.start_link(children, strategy: :one_for_all)
  end

  @spec apply(binary(), atom(), atom(), binary(), GenServer.server(), keyword()) ::
          binary()
  @doc """
  Run a python function in the `module_path`.
  Takes a single `binary` argument that is passed to the python
  function `(bytes) -> bytes`.

  `queue_timeout` is the timeout for this `apply/4/5/6` function.

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
    GenServer.call(python_server, {:apply, {path, module, fun, arg, py_timeout}}, queue_timeout)
  end
end

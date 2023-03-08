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

  @spec apply(binary(), atom(), atom(), binary(), GenServer.server(), timeout(), timeout()) ::
          binary()
  @doc """
  Run a python function in the `module_path`.
  Takes a single `binary` argument that is passed to the python
  function `(bytes) -> bytes`.
  """
  def apply(
        path,
        module,
        fun,
        arg,
        python_server \\ Python.Server,
        queue_timeout \\ :infinity,
        py_timeout \\ 5000
      ) do
    GenServer.call(python_server, {:apply, {path, module, fun, arg, py_timeout}}, queue_timeout)
  end
end

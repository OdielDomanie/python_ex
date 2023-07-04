defmodule Python.Server do
  @moduledoc """
  Genserver that spins up a Python server and handles messaging.
  """
  use GenServer

  # def python_path, do: Mix.Tasks.PythonSetup.python()
  @bridge_script :code.priv_dir(:python_ex) |> Path.join("bridge.py")

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:venv_dir], opts ++ [name: __MODULE__])
  end

  # Server (callbacks)

  @impl true
  def init(venv_dir) do
    python_path = venv_dir |> Mix.Tasks.PythonSetup.python_path()
    # Messages are preceded by msg length (4 bytes, big-endian)
    python_port =
      Port.open({:spawn_executable, python_path}, [
        :binary,
        :use_stdio,
        args: [@bridge_script],
        packet: 4
      ])

    {:ok, python_port}
  end

  @impl true
  def handle_call({:apply, {path, module, fun, arg, py_timeout}}, _from, port) do
    parent_pid = self()

    send_return = fn ->
      # Need to change owner
      Port.connect(port, self())
      port_ref = Port.monitor(port)
      # prefixed
      Port.command(port, "p" <> path)
      Port.command(port, "m" <> Atom.to_string(module))
      Port.command(port, "f" <> Atom.to_string(fun))
      Port.command(port, "a" <> arg)

      receive do
        {port, {:data, "r" <> result}} ->
          Port.connect(port, parent_pid)
          :erlang.unlink(port)
          Port.demonitor(port_ref)
          result

        {:DOWN, ^port_ref, :port, ^port, reason} ->
          raise(inspect({:python_down, reason}))

        other ->
          Port.connect(port, parent_pid)
          :erlang.unlink(port)
          raise(inspect({:bad_python_response, other}))
      end
    end

    # Do it in a seperate process because GenServer can't `receive`.
    result =
      Task.async(send_return)
      |> Task.await(py_timeout)

    {:reply, result, port}
  end
end

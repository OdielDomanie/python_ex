defmodule Mix.Tasks.PythonClean do
  @moduledoc """
  Deletes what is created by `python.setup`.
  """

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Path.join(Mix.Project.build_path(), "venv")
    |> File.rm_rf()
  end
end

defmodule PythonExTest do
  use ExUnit.Case
  doctest Python

  test "run a python function" do
    venv_path = Mix.Project.build_path() |> Path.join("test_pyvenv")

    {:ok, python_path} = Python.install_venv(venv_path)

    :ok = Python.install_pip_pckgs(python_path, ["yt-dlp==2023.3.4", "numpy"])

    {:ok, pid} = Python.Server.start_link(venv_dir: venv_path)

    test_dir = "test"

    assert "hellohello" ==
             Python.apply(test_dir, :test_script, :test_fun, "hello", pid)
  end
end

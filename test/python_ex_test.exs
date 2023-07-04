defmodule PythonExTest do
  use ExUnit.Case
  doctest Python

  test "run a python function" do
    venv_path = Mix.Project.build_path() |> Path.join("test_pyvenv")

    {:ok, _sv_pid} =
      Python.start(nil,
        pip_pckgs: ["yt-dlp==2023.3.4", "numpy"],
        venv_path: venv_path
      )

    test_dir = "test"

    assert "hellohello" ==
             Python.apply(test_dir, :test_script, :test_fun, "hello")
  end
end

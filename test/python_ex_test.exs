defmodule PythonExTest do
  use ExUnit.Case
  doctest Python

  test "project creates venv and installs deps via pip" do
    test_app_dir = Path.join(__DIR__, "test_app")

    assert {_out, 0} =
             System.cmd("mix", ["deps.clean", "--all"], cd: test_app_dir, stderr_to_stdout: true)

    # What is the proper return code?
    assert {_out, _ret} = System.cmd("mix", ["compile"], cd: test_app_dir, stderr_to_stdout: true)

    assert {"hellohello", 0} ==
             System.cmd("elixir", ["--sname", "test", "-S", "mix", "run"],
               cd: test_app_dir,
               stderr_to_stdout: true
             )
  end
end

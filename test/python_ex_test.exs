defmodule PythonExTest do
  use ExUnit.Case
  doctest PythonEx

  test "Creates a venv, installs pip pkgs, and calls funs" do
    assert PythonEx.hello() == :world
  end
end

defmodule PythonExTest do
  use ExUnit.Case
  doctest PythonEx

  test "greets the world" do
    assert PythonEx.hello() == :world
  end
end

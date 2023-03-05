defmodule TestProjTest do
  use ExUnit.Case
  doctest TestProj

  test "greets the world" do
    assert TestProj.hello() == :world
  end
end

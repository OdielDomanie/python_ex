defmodule TestApp do
  @moduledoc false

  use Application

  def start(_, _) do
    Python.call(:test_script, :test, "hello")
  end
end

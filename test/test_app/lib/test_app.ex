defmodule TestApp do
  @moduledoc false

  use Application

  @impl true
  def start(_, _) do
    priv_dir = :code.priv_dir(:test_app) |> to_string()

    Python.apply(priv_dir, :test_script, :test_fun, "hello")
    |> IO.write()

    {:ok, self()}
  end
end

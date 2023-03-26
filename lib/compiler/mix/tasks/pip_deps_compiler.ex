defmodule Mix.Tasks.Compile.PipDeps do
  @moduledoc """
  Create a Python venv and install dependencies via pip.
  `mix.exs` should have two more keys
  `:python_bin` and `:pip_deps`.
  """

  use Mix.Task.Compiler

  import Mix.Tasks.Compile.Python

  # Compiler must return {:ok | :noop | :error, [diagnostic]}
  def run(_args) do
    pip_install()
  end

  defp pip_install() do
    case Mix.Project.config() |> Keyword.get(:pip_deps) do
      nil ->
        {:noop, []}

      deps when is_list(deps) ->
        _ =
          System.cmd(
            python(),
            ["-m", "pip", "install", "-U", "pip", "wheel", "setuptools"]
          )

        pip_install_deps()
    end
  end

  defp pip_install_deps() do
    pip_deps = Mix.Project.config() |> Keyword.fetch!(:pip_deps)

    {out, ret} =
      System.cmd(
        python(),
        [
          "-m",
          "pip",
          "install",
          "-U",
          "--quiet",
          "--report",
          "-"
          | pip_deps
        ],
        stderr_to_stdout: false
      )

    case {out, ret} do
      {out_json, 0} ->
        new_installs?(out_json)

      {out, ret} ->
        errdiag_from_cmd({out, ret})
    end
  end

  # defp new_installs?(""), do: {:noop, []}

  defp new_installs?(json) do
    %{
      "version" => "1",
      "install" => installs
    } = Jason.decode!(json)

    if installs == [] do
      {:noop, []}
    else
      {:ok, []}
    end
  end

  defp errdiag_from_cmd({out, ret}) do
    {:error,
     [
       %Mix.Task.Compiler.Diagnostic{
         compiler_name: "PipDeps",
         details: inspect(out),
         file: Mix.Project.project_file(),
         message: "pip returns #{ret}",
         position: 0,
         severity: :error
       }
     ]}
  end

  def clean() do
    System.shell("pip freeze --local --user --disable-pip-version-check\
      | cut -d \"@\" -f1\
      | xargs pip uninstall -y --require-virtualenv --no-input --disable-pip-version-check")
  end
end

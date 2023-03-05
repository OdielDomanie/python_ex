defmodule Mix.Tasks.Compile.Python do
  @moduledoc """
  Create a Python venv and install dependencies via pip.
  pip depencies are declared in `python_depencies/0` in `mix.exs`.
  """

  use Mix.Task.Compiler

  @source_path "python_source"
  @bin_dir Path.join(Mix.Project.app_path(), "python")

  def run(_args) do
    Mix.Project.pop()

    # Hard coded to 3.11 for now, might make it variable later.

    source = Path.join(Mix.Project.app_path(), @source_path)
    File.mkdir(source)

    System.cmd("wget", ["https://www.python.org/ftp/python/3.10.10/Python-3.10.10.tgz"],
      cd: source
    )

    System.cmd("tar", ["xf", "Python-3.10.10.tgz", "-C", source, "--strip-components=1"],
      cd: source
    )

    File.mkdir(@bin_dir)

    case Mix.env() do
      _ ->
        with {_, 0} <-
               System.cmd(
                 Path.join(source, "configure"),
                 ["--with-ensurepip=install", "--prefix=" <> @bin_dir],
                 cd: source
               ),
             {_, 0} <- System.cmd("make", ["-s", "-j"], cd: source),
             {_, 0} <- System.cmd("make", ["install"], cd: source) do
          :ok
        else
          {out, code} = error ->
            %Mix.Task.Compiler.Diagnostic{
              compiler_name: "Python",
              details: error,
              file: __ENV__.file,
              message: inspect(out),
              position: 0,
              severity: :error
            }
        end
    end
  end
end

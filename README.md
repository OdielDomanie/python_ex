# PythonEx

Call Python functions from Elixir.



## Installation
(Coming soon)
~~If [available in Hex](https://hex.pm/docs/publish), the package can be installed~~
by adding `python_ex` to your list of dependencies, and optionally `:pip_deps` to the tail of the list of compilers in `mix.exs`:

```elixir
def deps do
  [
    {:python_ex, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
# Set up a python venv
{:ok, python_path} = Python.install_venv(venv_path, "python3")
# Install packages via pip
:ok = Python.install_pip_pckgs(python_path, ["numpy"])
# Start the server.
{:ok, pid} = Python.Server.start_link(venv_dir: "venv")

my_python_package = :code.priv_dir(:my_app) |> to_string()

# Call the Python function `my_python_module.my_echo_fun("hello")`
Python.apply(my_python_package, :my_python_module, :my_echo_fun, "hello")
# => "hello"
```

~~Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm).~~
Once published, the docs can be found at <https://hexdocs.pm/python_ex>.



Use `Python.apply(module_directory, :module_name, :function_name, arg)`
to call a Python function with a single binary argument.
* The module directory is recommended to be the `priv` folder.
* The module name is in the format of an `import` statement, eg. `:"mypackage.mymodule"`.
* The function is called with a single `binary`/`bytes` argument,
* and the Python function is expected to return a `bytes`/`binary` value.

# PythonEx

Call Python functions from Elixir!

**Simple:** This library only ever has just a single function( and an optional GenServer.)

```elixir
priv_dir = :code.priv_dir(:my_app) |> to_string()
Python.apply(priv_dir, :my_python_module, :my_echo_fun, "hello")
# => "hello"
```

## Installation
(Coming soon)
~~If [available in Hex](https://hex.pm/docs/publish), the package can be installed~~
by adding `python_ex` to your list of dependencies, and `:python` to the tail of the list of compilers in `mix.exs`:

```elixir
def project do
    [
      ...
      compilers: Mix.compilers() ++ [:python],
      pip_deps: pip_deps()
    ]
end

def deps do
  [
    {:python_ex, "~> 0.1.0"}
  ]
end

# Optional
defp pip_deps do
  [
    "numpy>=1.24"
  ]
end
```

## Usage

~~Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on [HexDocs](https://hexdocs.pm).~~
Once published, the docs can be found at <https://hexdocs.pm/python_ex>.

When compiled for the first time, PythonEx generates a Python virtual environment inside the Mix build directory, using the `PYTHON` environment variable (`python` by default) as the source Python binary.

When run, the PythonEx app automatically spins up a Python server that handles calls.

Use `Python.apply(module_directory, :module_name, :function_name, arg)`
to call a Python function with a single binary argument.
* The module directory is recommended to be the `priv` folder.
* The module name is in the format of an `import` statement, eg. `:"mypackage.mymodule"`.
* The function is called with a single `binary`/`bytes` argument,
* and the Python function is expected to return a `bytes`/`binary` value.


Optionally, you can manually start Python Genservers in `Python.Server`.

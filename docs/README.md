# lua-error Documentation

New here? The [Quick Start](../README.md#quick-start) catches a Lua error, then raises and catches an error class of your own, in about 5 minutes.

## Start

- [Quick Start](../README.md#quick-start): get the code, catch an error, raise your own kind of error

## Use

- [API reference](api.md): `try`, `catch`, `finally`, the `Error` class, subclasses, known issues
- [dmc-error](https://github.com/dmccuskey/dmc-error): the module packaged like the other DMC Solar2D libraries
- [lua-class](https://github.com/dmccuskey/lua-class): the class model behind `Error` and its subclasses

## Contribute

- [Development](development.md): which files are copies, tests
- [Issues](https://github.com/dmccuskey/lua-error/issues)

## Project Structure

```text
README.md                   landing page and Quick Start
LICENSE
docs/                       this documentation
dmc_lua/
├── lua_error.lua           the module
└── lua_class.lua           what it needs, from lua-class (copy)
Snakefile                   build rules, for DMC-Lua-Library
spec/
└── lua_error_spec.lua      tests (busted)
```

# Development

How lua-error is put together and tested.

## Where the Code Lives

Only `dmc_lua/lua_error.lua` is written in this repository. `dmc_lua/lua_class.lua` is a copy from [lua-class](https://github.com/dmccuskey/lua-class), kept so the module and its tests work from a plain clone. Fix it there, then copy it here by hand.

[DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies `lua_error.lua` into its `dmc_lua/` with its Snakemake build (the `Snakefile` here registers the module and its requirement, lua-class), and every DMC Solar2D library copies it from there into `dmc_corona/lib/dmc_lua/`. [dmc-error](https://github.com/dmccuskey/dmc-error) is the Solar2D front end for it. Other DMC libraries use it for their own errors: lua-bytearray, lua-files, dmc-websockets, dmc-wamp, dmc-autostore.

## Testing

The tests are in `spec/lua_error_spec.lua` and use [busted](https://lunarmodules.github.io/busted/) under Lua 5.1 (`luarocks install busted`). From the repository's root folder:

```sh
busted spec
```

```text
++++++++++++
12 successes / 0 failures / 0 errors / 0 pending : 0.002634 seconds
```

They create `Error` objects and a subclass, and check their fields and `__tostring__()`. They don't test `try`, `catch` or `finally`, nor anything in the [Known Issues](api.md#known-issues).

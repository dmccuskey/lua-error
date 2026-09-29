# Development

How lua-error is put together and tested.

## Where the Code Lives

Only `dmc_lua/lua_error.lua` is written in this repository. `dmc_lua/lua_class.lua` is a copy from [lua-class](https://github.com/dmccuskey/lua-class), kept so the module and its tests work from a plain clone. Fix it there, then copy it here by hand.

[DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies `lua_error.lua` into its `dmc_lua/` with its Snakemake build (the `Snakefile` here registers the module and its requirement, lua-class), and every DMC Solar2D library copies it from there into `dmc_corona/lib/dmc_lua/`. [dmc-error](https://github.com/dmccuskey/dmc-error) is the Solar2D front end for it. Other DMC libraries use it for their own errors: lua-bytearray, lua-files, dmc-websockets, dmc-wamp, dmc-autostore.

## Testing

The tests are in `spec/` and use [busted](https://lunarmodules.github.io/busted/) under Lua 5.1 (`luarocks install busted`). From the repository's root folder:

```sh
busted spec
```

```text
+++++++++++++++++++++++++++++++
31 successes / 0 failures / 0 errors / 0 pending : 0.005805 seconds
```

`spec/lua_error_spec.lua` creates `Error` objects and a subclass, and checks their fields and `__tostring__()`. `spec/try_spec.lua` tests `try`, `catch` and `finally`: every combination of the parts, the return values, errors going on up, and where an error's traceback starts.

busted has a `finally()` of its own in a spec's environment, so `try_spec.lua` takes the module's `try`, `catch` and `finally` from `_G`.

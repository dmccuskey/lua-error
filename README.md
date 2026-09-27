# lua-error

`try`, `catch` and `finally` for Lua 5.1, and error classes you can raise and recognize.

Lua raises errors with `error()` and catches them with `pcall()`. lua-error puts a structure around them, modeled on Python's `try` / `except` / `finally`, and adds an `Error` class to raise instead of a string, so a handler can tell its own errors from everyone else's:

```lua
local Error = require 'lua_error'

try{
	function()
		error( 'something went wrong' )
	end,

	catch{
		function( err )
			print( 'caught:', err )
		end
	},

	finally{
		function()
			print( 'clean up' )
		end
	}
}
```

## Features

- `try{}`, `catch{}` and `finally{}`: three global functions that read like the statements in other languages
- The error, a string or an object, is passed to the `catch` function
- An `Error` base class with a message, a prefix and the traceback from where it was created
- Subclass `Error` for your own kinds of error, and tell them apart with `isa()`
- `try()` returns the value of the function it ran
- Pure Lua 5.1, one file plus [lua-class](https://github.com/dmccuskey/lua-class); MIT licensed

`finally` has bugs: it doesn't run on success unless there is a `catch`, and it doesn't run when the `catch` raises an error. See [Known Issues](docs/api.md#known-issues).

## Quick Start

The following steps will get you up and running in about 5 minutes with Lua 5.1 on macOS or Linux. You will catch a Lua error, then raise and catch an error class of your own.

Prerequisites: Lua 5.1 (`lua -v` shows `Lua 5.1.x`) and git.

### 1. Get the Code

In an empty folder:

```sh
git clone https://github.com/dmccuskey/lua-error.git
```

`lua-error/dmc_lua/` holds the module, `lua_error.lua`, and the one it needs, `lua_class.lua`.

### 2. Catch an Error

Create `main.lua` in the same folder:

```lua
package.path = './lua-error/dmc_lua/?.lua;' .. package.path
local Error = require 'lua_error'

try{
	function()
		local player = nil
		print( player.name )  -- a mistake: raises an error
	end,

	catch{
		function( err )
			print( 'caught:', err )
		end
	},

	finally{
		function()
			print( 'finally: runs either way' )
		end
	}
}

print( 'still running' )
```

Run it:

```sh
lua main.lua
```

```text
caught:	main.lua:7: attempt to index local 'player' (a nil value)
finally: runs either way
still running
```

If it shows `module 'lua_error' not found`, run it from the folder that holds `lua-error/`.

Requiring `lua_error` creates the global functions `try`, `catch` and `finally`. `try` runs the first function; when it raises an error, the `catch` function gets the error, and the program goes on.

**Going further:** what `try()` returns, and which parts can be left out ([try, catch, finally](docs/api.md#try-catch-finally)).

### 3. Raise Your Own Kind of Error

Add this to the end of `main.lua`:

```lua
local Class = require 'lua_class'

local NetworkError = Class.newClass( Error, { name="Network Error" } )

local function loadScores( url )
	error( NetworkError( 'no connection to ' .. url ) )
end

try{
	function()
		loadScores( 'https://scores.example.com/top10' )
	end,

	catch{
		function( err )
			if type( err )=='table' and err:isa( NetworkError ) then
				print( 'caught:', err.NAME, '/', err.message )
			else
				error( err )  -- not ours: raise it again
			end
		end
	}
}
```

`lua main.lua` now also shows:

```text
caught:	Network Error	/	no connection to https://scores.example.com/top10
```

`NetworkError` is a subclass of `Error`; calling it creates an error object, and `error()` raises it. The `catch` checks the kind of error with `isa()` and raises anything else again. Check `type( err )=='table'` first: Lua's own errors are strings, which have no `isa()`.

**Going further:** the error object's fields, prefixes and default messages ([The Error Class](docs/api.md#the-error-class)); what happens to an error object nobody catches ([Known Issues](docs/api.md#known-issues)).

To update, pull the repository again (`git -C lua-error pull`), or replace the files in `dmc_lua/` with the newer ones.

## Documentation

- [API reference](docs/api.md): `try`, `catch`, `finally`, the `Error` class, subclasses, known issues
- [dmc-error](https://github.com/dmccuskey/dmc-error): the same module for Solar2D (formerly Corona SDK), set up like the other DMC Solar2D libraries
- [lua-class](https://github.com/dmccuskey/lua-class): the class model `Error` is built on

Everything else is listed on the [documentation home](docs/README.md).

## License

lua-error is released under the [MIT License](LICENSE).

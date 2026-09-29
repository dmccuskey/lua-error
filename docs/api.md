# API Reference

lua-error 0.4.1: `try`, `catch`, `finally` and the `Error` class. For a first run, see the [Quick Start](../README.md#quick-start).

| Name | What it is |
|---|---|
| [`require 'lua_error'`](#the-module) | returns the `Error` class, and creates the globals below |
| [`try{ f, catch{...}, finally{...} }`](#try-catch-finally) | runs `f`, catches its error, cleans up |
| [`catch{ f }`](#catch) | marks the function that handles the error |
| [`finally{ f }`](#finally) | marks the function that runs last |
| [`Error( message, params )`](#creating-an-error) | creates an error object to raise with `error()` |
| [`newClass( Error, { name=... } )`](#your-own-errors) | a kind of error of your own |
| [`err:isa( Class )`](#telling-errors-apart) | whether an error is of a class, or a subclass of it |

The two parts can be used apart: `try` catches any error, a string or an object, and an `Error` can be caught with plain `pcall()`.

## The Module

```lua
local Error = require 'lua_error'
```

It needs `lua_class` on the Lua path ([lua-class](https://github.com/dmccuskey/lua-class); a copy is in `dmc_lua/`). Requiring it:

- returns the `Error` class
- sets the globals `try`, `catch` and `finally`
- loads lua-class, which sets the global `newClass` (see [lua-class](https://github.com/dmccuskey/lua-class)); lua-error itself uses `Class.newClass`, so it also works with that global turned off

The version is in `Error.__version` (`"0.4.1"`).

## try, catch, finally

```lua
local result = try{
	function()
		-- code that may raise an error
		return 'a value'
	end,

	catch{
		function( err )
			-- handle the error
		end
	},

	finally{
		function()
			-- clean up
		end
	}
}
```

`try{ ... }` is a call of `try()` with one table: Lua lets a function called with a table leave out the parentheses. The table holds the function to run first, then a catch, a finally, or both. `catch{ f }` and `finally{ f }` mark `f` as the one or the other, so either can be left out:

```lua
try{ f, catch{ g }, finally{ h } }
try{ f, catch{ g } }
try{ f, finally{ h } }
try( { f, catch( { g } ), finally( { h } ) } )   -- the same as the first
```

Plain functions, without `catch{}` or `finally{}`, also work, by their place: second is the catch, third the finally (`try{ f, g, h }`, `try{ f, nil, h }`).

What happens:

1. `try` runs the first function with `pcall()`, with no arguments.
2. If it raised an error, and there is a catch function, the catch function is called with the error. The error is what was given to `error()`: a string (for Lua's own errors, with the file and line in front) or an object.
3. If there is a finally function, it is called, with no arguments, whatever happened before.
4. If the function raised an error and there is no catch, or the catch raised one, that error goes on up, as it was. Otherwise `try` returns the values of the function, or of the catch if there was an error.

`try{}` without a function is an error: `lua-error: missing function for try()`.

### catch

The catch function gets the error and decides what to do with it. To pass on an error it doesn't handle, it raises it again with `error( err )`:

```lua
catch{
	function( err )
		if type( err )=='table' and err:isa( NetworkError ) then
			showOfflineMessage()
		else
			error( err )  -- not ours
		end
	end
}
```

When there is no catch, the error goes on up, as if there were no `try`, after the finally function has run.

### finally

The finally function runs after the function and the catch, for cleanup that has to happen either way: closing a file, hiding a spinner. It runs on success, on an error, with or without a catch, and when the catch raises an error, for example to pass on one it doesn't handle; the error goes on up after it. Its return values are ignored.

```lua
local fh = assert( io.open( path ) )
try{
	function() parse( fh:read( '*a' ) ) end,
	finally{ function() fh:close() end }   -- closed, and a parse error still goes on up
}
```

### Return Value

```lua
local w, h = try{ function() return 640, 480 end }                   --> 640, 480
local size = try{
	function() error( 'no disk' ) end,
	catch{ function( err ) return 0 end }
}                                                                    --> 0
```

On success, `try` returns every value of the function. When the catch handled an error, `try` returns what the catch returned: nothing, unless it returns a value, such as a default. When an error goes on up, `try` returns nothing.

## The Error Class

### Creating an Error

```lua
local err = Error( message, params )     -- or Error:new( message, params )
error( err )
```

| Argument | Default | What it is |
|---|---|---|
| `message` | `Error.DEFAULT_MESSAGE`, `"There was an error"` | what went wrong |
| `params.prefix` | `Error.DEFAULT_PREFIX`, `"ERROR: "` | put in front of the message when it's turned into a string |

The object has these fields:

| Field | What it is |
|---|---|
| `err.message` | the message |
| `err.prefix` | the prefix |
| `err.traceback` | the stack traceback from where the object was created |
| `err.NAME` | the class's name: `"Error Instance"` for `Error`, the `name` given to `newClass()` for a subclass |

`tostring( err )`, and so `print( err )`, gives the prefix, the message, a newline and the traceback:

```text
ERROR: no connection to https://scores.example.com/top10
stack traceback:
	main.lua:29: in function 'loadScores'
	...
```

The traceback starts at the line that created the object (here in `loadScores()`, from the Quick Start), not inside lua-error, lua-class or the constructors of its classes.

Unlike a string, an error object doesn't get the file and line in front of its message: the traceback holds them.

### Your Own Errors

Make a subclass with lua-class's `newClass()`, the `Class.newClass` function or the global `newClass`:

```lua
local Class = require 'lua_class'

local NetworkError = Class.newClass( Error, { name="Network Error" } )
NetworkError.DEFAULT_MESSAGE = "No network connection"
NetworkError.DEFAULT_PREFIX = "NETWORK: "

error( NetworkError() )                -- NETWORK: No network connection
error( NetworkError( 'timed out' ) )   -- NETWORK: timed out
```

`name` becomes the subclass's `NAME`. The class constants set the defaults for that class and its own subclasses. A subclass can be subclassed again, `Class.newClass( NetworkError, { name="Timeout Error" } )`, to make a family of errors that a catch can handle at any level. How classes work, including constructors of your own (`__new__`, which must call the parent's with `self:superCall( '__new__', ... )`), is in [lua-class](https://github.com/dmccuskey/lua-class).

In a module that raises several kinds of error, a common layout is a file that creates them and returns them in a table, as dmc-websockets' `exception.lua` and lua-bytearray's `exceptions.lua` do.

### Telling Errors Apart

`err:isa( Class )` is true when `err` was created from `Class` or one of its subclasses:

```lua
local err = NetworkError( 'timed out' )

err:isa( NetworkError )   --> true
err:isa( Error )          --> true
err:isa( ParseError )     --> false
```

Lua's own errors, and anything raised with `error( 'a string' )`, are strings, which have no `isa()`: check `type( err )=='table'` first.

## Known Issues

- **An `Error` object nobody catches loses its message.** Lua 5.1 prints `lua: (error object is not a string)`; the Solar2D Simulator prints nothing at all. Catch your own errors, or raise `tostring( err )` where they may reach the top.
- An error that goes on up through `try` (no catch, or the catch raised it) loses the stack below `try`: a string error's traceback starts at `try`. An `Error` object keeps its own `traceback`.
- `try`, `catch` and `finally` are always globals, and can't be turned off.
- Error objects have no file and line in front of their message, unlike string errors: the place is only in the traceback.

## Background

The design comes from these sources:

- [try/catch/finally in Lua](https://gist.github.com/cwarden/1207556), the gist `try` is based on
- [Error Handling and Exceptions](https://www.lua.org/pil/8.4.html) in *Programming in Lua*
- [Exceptions in Lua](https://www.lua.org/wshop06/Belmonte.pdf), slides from the Lua Workshop 2006

## lua-error ##

Robust try, catch, finally error handling for Lua which features:

* try, catch, finally
* custom error objects


### Quick ###

```
-- import creates a base Error class and global funcs try(), catch(), finally()

local Error = require 'lua_error'

-- do this anywhere in your code:

try{
  function()
    -- make a call which could raise an error
  end,
  catch{
    function( err )
      -- handle the error
    end
  },
  finally{
    function()
      -- do some cleanup
    end
  }
}
```

The `catch` and `finally` are optional.



### Overview ###

The library is a culmination of several ideas found on the Internet put into a cohesive package. (see References below). It was also inspired by the error handling in Python.

There are two different components to this library which can either be used together or independantly:

1. *functions*: `try`, `catch`, and `finally` which give structure
2. *Error object class*: which can be used by itself or subclassed for more refined errors


#### Lua Errors ####

The basic pieces of error handling built into Lua are the functions `error()` and `pcall()`. `error()` is used to raise an error condition in a program:

```
error( "this is my error" )
```

And creates something like this:

```
my_lua_file.lua:17: this is my error
stack traceback:
	[C]: in function 'error'
	/path_to_file/my_lua_file.lua:17: in main chunk
	[C]: in function 'require'
	?: in function 'require'
	/path_to_file/main.lua:104: in function 'main'
	/path_to_file/main.lua:110: in main chunk
```

Often `error()` is only used to create string-errors. The drawback to these types of errors is they are fragile and hard to represent other meaningful errors (eg, `system.error.overflow`, `system.error.protocol`, `system.error.authentication`, etc).

Though one feature of `error()` which we can use to our advantage is that it will pass back anything you send in (including objects!). More on this later.


#### try(), catch(), finally() ####

This function trio is the backbone of awesome error handling. The following is the basic structure using all three of the functions. It was chosen for its readability.

Note: in the example below, `<func ref>` represents a function reference, for example: `function() -- do stuff end`.

```
try{
  <func ref>,
  catch{
    <func ref>
  },
  finally{
    <func ref>
  }
}
```


This format works because it takes advantage of Lua's dual-way to call functions, eg:

`hello()` or `hello{}`, the latter being equivalent to `hello( {} )`

So essentially this format is really a function `try()` which accepts a single argument – an array of up to three function references). The order of the references is `try`, `catch`, and `finally`.

The `catch` and `finally` terms are themselves global functions like `try`, and like `try` these each take a single argument – an array of function references, but only contain a single function.


Here are some alternate layouts showing the same thing:

```
flattened out:
try{ <func ref>, catch{ <func ref> }, finally{ <func ref> } }

same thing, including parens:
try( { <func ref>, catch({ <func ref> }), finally({ <func ref> }) } )
```


#### Custom Errors ####

The objects in this framework use `lua_objects` as the backbone. This example use

The unit test has a simple example of subclassing `Error` to make other types of errors. But here's a quick example:

```
-- imports
local Error = require 'lua_error'
local Objects = require 'lua_objects'

-- setup some aliases to make code cleaner
local newClass = Objects.newClass

-- create custom error class
local ProtocolError = newClass( Error, { name="Protocol Error" } )

-- raise an error
error( ProtocolError( "bad protocol" ) )

```


#### Example ####

The following code snippet is a real-life example taken from `dmc_wamp`:

```
	try{
		function()
			self._session:onOpen( { transport=self } )
		end,

		catch{
			function(e)
				if type(e)=='string' then
					error( e )
				elseif e:isa( Error.ProtocolError ) then
					print( e.traceback )
					self:_bailout{
						code=WebSocket.CLOSE_STATUS_CODE_PROTOCOL_ERROR,
						reason="WAMP Protocol Error"
					}
				else
					print( e.traceback )
					self:_bailout{
						code=WebSocket.CLOSE_STATUS_CODE_INTERNAL_ERROR,
						reason="WAMP Internal Error ({})"
					}
				end
			end
		}
	}
```

In the `catch` you see that:
* first, we're checking to see if it's a regular string-type error. if so, re-raise the error.
* second, we're checking the object-type of the error using the method `isa()`, looking for a `ProtocolError`
* third, it's not an error we can handle, so bailout with an internal error.


###References###

* https://gist.github.com/cwarden/1207556
* http://www.lua.org/pil/8.4.html
* http://www.lua.org/wshop06/Belmonte.pdf

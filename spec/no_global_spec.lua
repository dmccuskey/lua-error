--====================================================================--
-- spec/no_global_spec.lua
--
-- lua-error loads with lua-class's global newClass turned off
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path


describe( "Module Test: lua_error.lua without the global newClass", function()

	it( "loads and makes errors", function()
		package.loaded['lua_class'] = nil
		package.loaded['lua_error'] = nil
		local Class = require 'lua_class'
		Class.setNewClassGlobal( false )

		local ok, Error = pcall( require, 'lua_error' )
		Class.setNewClassGlobal( true )

		assert.is_true( ok, tostring( Error ) )
		local err = Error( "bad" )
		assert.is.equal( err.message, "bad" )
		assert.is_true( err:isa( Error ) )
	end)

end)

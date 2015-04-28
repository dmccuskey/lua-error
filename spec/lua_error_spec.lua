--====================================================================--
-- lua_error_spec.lua
--
-- Unit Testing for lua_error using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path



--====================================================================--
--== Test: Lua Error
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Error = require 'lua_error'



--====================================================================--
--== Subclass Test


local ProtocolError = newClass( Error, { name="Protocol Error" } )



--====================================================================--
--== Support Functions


local function createError( ... )
	return Error:new( ... )
end



--====================================================================--
--== Module Testing
--====================================================================--


describe( "Module Test: lua_error.lua", function()


	describe( "Test: object properties", function()

		local err

		before_each( function()
			err = createError()
		end)

		after_each( function()
			err = nil
		end)

		it( "is object", function()
			assert( type(err)=='table', "not an object" )
			assert( err:isa( Error ), "incorrect Object type" )
		end)

		it( "has properties", function()
			assert( err.NAME == "Error Instance", "incorrect NAME" )
			assert( err.prefix == "ERROR: ", "incorrect prefix" )
			assert( err.message == "There was an error", "incorrect message" )
			assert( err.traceback, "missing traceback" )
		end)

		it( "outputs string version", function()
			assert( err:__tostring__() == table.concat( { err.prefix, err.message, "\n", err.traceback } ), "incorrect error message" )
		end)

	end)



	describe( "Test: message", function()

		local err

		before_each( function()
			err = createError( "new message" )
		end)

		after_each( function()
			err = nil
		end)

		it( "is object", function()
			assert( type(err)=='table', "not an object" )
			assert( err:isa( Error ), "incorrect Object type" )
		end)

		it( "has properties", function()
			assert( err.NAME == "Error Instance", "incorrect NAME" )
			assert( err.prefix == "ERROR: ", "incorrect prefix" )
			assert( err.message == "new message", "incorrect message" )
			assert( err.traceback, "missing traceback" )
		end)

		it( "outputs string version", function()
			assert( err:__tostring__() == table.concat( { err.prefix, err.message, "\n", err.traceback } ), "incorrect error message" )
		end)

	end)



	describe( "Test: params", function()

		local err

		before_each( function()
			err = createError( nil, { prefix="W00T: " } )
		end)

		after_each( function()
			err = nil
		end)

		it( "is object", function()
			assert( type(err)=='table' )
			assert( err:isa( Error ), "incorrect Object type" )
		end)

		it( "has properties", function()
			assert( err.NAME == "Error Instance", "incorrect NAME" )
			assert( err.prefix == "W00T: ", "incorrect prefix" )
			assert( err.message == "There was an error", "incorrect message" )
			assert( err.traceback, "missing traceback" )
		end)

		it( "outputs string version", function()
			assert( err:__tostring__() == table.concat( { err.prefix, err.message, "\n", err.traceback } ), "incorrect error message" )
		end)

	end)




	describe( "Test: Protocol", function()

		local MSG = "bad element in protocol"
		local err

		before_each( function()
			err = ProtocolError( MSG )
		end)

		after_each( function()
			err = nil
		end)

		it( "is object", function()
			assert( type(err)=='table' )
			assert( err:isa( ProtocolError ), "incorrect Object type" )
		end)

		it( "has properties", function()
			assert( err.NAME == "Protocol Error", "incorrect NAME" )
			assert( err.prefix == "ERROR: ", "incorrect prefix" )
			assert( err.message == MSG, "incorrect message" )
			assert( err.traceback, "missing traceback" )
		end)

		it( "outputs string version", function()
			assert( err:__tostring__() == table.concat( { err.prefix, err.message, "\n", err.traceback } ), "incorrect error message" )
		end)

	end)

end)




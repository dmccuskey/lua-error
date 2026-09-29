--====================================================================--
-- try_spec.lua
--
-- Unit Testing for try, catch and finally using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path



--====================================================================--
--== Imports


local Error = require 'lua_error'

-- busted has a finally() of its own: use the module's globals
local try, catch, finally = _G.try, _G.catch, _G.finally



--====================================================================--
--== Support Functions


local function fails()
	error( "failed", 0 )
end

local function succeeds()
	return 1, nil, 3
end

-- returns ok flag and error message of calling f
local function raises( f )
	local ok, err = pcall( f )
	return not ok, err
end



--====================================================================--
--== Module Testing
--====================================================================--


describe( "Module Test: try, catch, finally", function()


	describe( "Test: try", function()

		it( "returns every value of the function", function()
			local a, b, c = try{ succeeds }
			assert.are.equal( 1, a )
			assert.is_nil( b )
			assert.are.equal( 3, c )
			assert.are.equal( 3, select( '#', try{ succeeds } ) )
		end)

		it( "raises the error again without a catch", function()
			local raised, err = raises( function() try{ fails } end )
			assert.is_true( raised )
			assert.are.equal( "failed", err )
		end)

		it( "keeps an error object when raising it again", function()
			local e = Error( "object" )
			local _, err = raises( function()
				try{ function() error( e ) end }
			end)
			assert.are.equal( e, err )
		end)

		it( "requires a function", function()
			assert.is_true( raises( function() try{} end ) )
		end)

	end)


	describe( "Test: catch", function()

		it( "gets the error", function()
			local got
			try{ fails, catch{ function( e ) got = e end } }
			assert.are.equal( "failed", got )
		end)

		it( "isn't called on success", function()
			local called = false
			try{ succeeds, catch{ function() called = true end } }
			assert.is_false( called )
		end)

		it( "gives try its return values", function()
			local a, b = try{ fails, catch{ function() return 'x', 'y' end } }
			assert.are.equal( 'x', a )
			assert.are.equal( 'y', b )
			assert.are.equal( 0, select( '#', try{ fails, catch{ function() end } } ) )
		end)

		it( "can raise an error", function()
			local raised, err = raises( function()
				try{ fails, catch{ function( e ) error( "again: "..e, 0 ) end } }
			end)
			assert.is_true( raised )
			assert.are.equal( "again: failed", err )
		end)

		it( "works as a plain function in second place", function()
			local got
			try{ fails, function( e ) got = e end }
			assert.are.equal( "failed", got )
		end)

	end)


	describe( "Test: finally", function()

		it( "runs on success", function()
			local ran = false
			try{ succeeds, catch{ function() end }, finally{ function() ran = true end } }
			assert.is_true( ran )
		end)

		it( "runs after a catch", function()
			local order = {}
			try{
				fails,
				catch{ function() order[#order+1] = 'catch' end },
				finally{ function() order[#order+1] = 'finally' end }
			}
			assert.are.same( { 'catch', 'finally' }, order )
		end)

		it( "runs on success without a catch", function()
			local ran, nargs = false, 'none'
			try{ succeeds, finally{ function( ... ) ran = true; nargs = select( "#", ... ) end } }
			assert.is_true( ran )
			assert.are.equal( 0, nargs )
		end)

		it( "runs without a catch, then the error goes on", function()
			local ran = false
			local raised, err = raises( function()
				try{ fails, finally{ function() ran = true end } }
			end)
			assert.is_true( ran )
			assert.is_true( raised )
			assert.are.equal( "failed", err )
		end)

		it( "runs when the catch raises, then the error goes on", function()
			local ran = false
			local raised, err = raises( function()
				try{
					fails,
					catch{ function() error( "from catch", 0 ) end },
					finally{ function() ran = true end }
				}
			end)
			assert.is_true( ran )
			assert.is_true( raised )
			assert.are.equal( "from catch", err )
		end)

		it( "works in third place with an empty catch place", function()
			local ran = false
			try{ succeeds, nil, finally{ function() ran = true end } }
			assert.is_true( ran )
		end)

		it( "works as a plain function in third place", function()
			local ran = false
			try{ succeeds, catch{ function() end }, function() ran = true end }
			assert.is_true( ran )
		end)

		it( "keeps the return values", function()
			local a, b, c = try{ succeeds, finally{ function() return 'no' end } }
			assert.are.same( { 1, nil, 3 }, { a, b, c } )
		end)

	end)


	describe( "Test: traceback", function()

		it( "starts where the error was created", function()
			local err = Error( "here" )
			local first = err.traceback:match( "\n%s*([^\n]*)" )
			assert.is_truthy( first:find( "try_spec.lua", 1, true ), first )
		end)

		it( "starts where a subclass error was created", function()
			local SubError = newClass( Error, { name="Sub Error" } )
			function SubError:__new__( ... )
				self:superCall( '__new__', ... )
				self.extra = true
			end
			local SubSubError = newClass( SubError, { name="Sub Sub Error" } )

			local line = debug.getinfo( 1, 'l' ).currentline + 1
			local err = SubSubError( "here" )
			assert.is_true( err.extra )
			local first = err.traceback:match( "\n%s*([^\n]*)" )
			assert.is_truthy( first:find( "try_spec.lua:"..line..":", 1, true ), first )
			assert.is_falsy( err.traceback:find( "lua_class.lua", 1, true ) )
			assert.is_falsy( err.traceback:find( "lua_error.lua", 1, true ) )
		end)

	end)

end)

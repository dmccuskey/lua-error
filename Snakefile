# lua-error

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "lua-error"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "lua-error",
	"module": {
		"dir": "dmc_lua",
		"files": [
				"lua_error.lua"
		],
		"requires": [
				"lua-class"
		]
	},
	"tests": {
		"dir": "spec",
		"files": [],
		"requires": []
	}
}

register( "lua-error", module_config )


# lua-error

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "lua-error"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "lua-error",
	"module": {
		"files": [
				"lua_error.lua"
		],
		"requires": [
				"lua-objects"
		]
	},
	"tests": {
		"files": [
		],
		"requires": [
		]
	}
}

register( "lua-error", module_config )


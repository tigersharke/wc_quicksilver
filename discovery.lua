-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.register_hint("find cinnabar",
	"group:cinnabar",
	"toolcap:cracky:3"
)

nodecore.register_hint("heat cinnabar cobble",
	{true, "heat cinnabar cobble"},
	"group:cin_react"
)

nodecore.register_hint("mercuriate bonded cloudstone bricks",
	"mercuriate bonded cloudstone bricks",
	"bond cloudstone bricks"
)

nodecore.register_hint("oxidize lode cube with quicksilver",
	"oxidize lode cube with quicksilver",
	"temper a lode cube"
)

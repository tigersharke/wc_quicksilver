-- LUALOCALS < ---------------------------------------------------------
local minetest, core, nodecore, nc
    = minetest, core, nodecore, nc
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

nc.register_hint("find cinnabar",
	"group:cinnabar",
	"toolcap:cracky:3"
)

nc.register_hint("heat cinnabar cobble",
	{true, "heat cinnabar cobble"},
	"group:cin_react"
)

nc.register_hint("mercuriate bonded cloudstone bricks",
	"mercuriate bonded cloudstone bricks",
	"bond cloudstone bricks"
)

nc.register_hint("oxidize lode cube with quicksilver",
	"oxidize lode cube with quicksilver",
	"temper a lode cube"
)

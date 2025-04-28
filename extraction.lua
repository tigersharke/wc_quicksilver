-- LUALOCALS < ---------------------------------------------------------
local minetest, core, nodecore, nc
    = minetest, core, nodecore, nc
-- LUALOCALS > ---------------------------------------------------------
local modname = core.get_current_modname()
local vapor = {name = modname.. ":vapor"}
----------------------------------------------------------------------
nc.register_craft({
		label = "heat cinnabar cobble",
		action = "cook",
		touchgroups = {flame = 3},
		neargroups = {coolant = 0},
		duration = 30,
		cookfx = true,
		indexkeys = {"group:cinnabar_cobble"},
		nodes = {
			{
				match = {groups = {cinnabar_cobble = true}},
				replace = modname .. ":cobble_hot"
			}
		}
	})
----------------------------------------------------------------------
core.register_abm({
		label = "release quicksilver vapor",
		nodenames = {modname .. ":cobble_hot"},
		interval = 1,
		chance = 1,
		action = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if not nc.air_pass(above) then return end
			nc.set_loud(pos, {name = "nc_terrain:cobble"})
			nc.witness(pos, "quicksilver vapor release")
			return nc.set_loud(above, vapor)
		end
	})

----------------------------------------------------------------------
nc.register_craft({
		label = "cinnabar cooling",
		action = "cook",
		touchgroups = {flame = 0},
		neargroups = {coolant = 0},
		duration = 240,
		priority = -1,
		cookfx = {smoke = true, hiss = true},
		indexkeys = {modname .. ":cobble_hot"},
		nodes = {
			{
				match = modname .. ":cobble_hot",
				replace = modname .. ":cinnabar"
			}
		}
	})
----------------------------------------------------------------------
nc.register_craft({
		label = "cinnabar quenching",
		action = "cook",
		touchgroups = {flame = 0},
		neargroups = {coolant = 1},
		cookfx = true,
		indexkeys = {modname .. ":cobble_hot"},
		nodes = {
			{
				match = modname .. ":cobble_hot",
				replace = modname .. ":cobble"
			}
		}
	})
----------------------------------------------------------------------
nc.register_cook_abm({nodenames = {"group:cinnabar_cobble"}, neighbors = {"group:flame"}})
nc.register_cook_abm({nodenames = {modname .. ":cobble_hot"}})
----------------------------------------------------------------------

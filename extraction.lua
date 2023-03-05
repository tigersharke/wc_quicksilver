-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local vapor = {name = modname.. ":vapor"}
----------------------------------------------------------------------
nodecore.register_craft({
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
minetest.register_abm({
		label = "release quicksilver vapor",
		nodenames = {modname .. ":cobble_hot"},
		interval = 1,
		chance = 1,
		action = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if not nodecore.air_pass(above) then return end
			nodecore.set_loud(pos, {name = "nc_terrain:cobble"})
			nodecore.witness(pos, "quicksilver vapor release")
			return nodecore.set_loud(above, vapor)
		end
	})

----------------------------------------------------------------------
nodecore.register_craft({
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
nodecore.register_craft({
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
nodecore.register_cook_abm({nodenames = {"group:cinnabar_cobble"}, neighbors = {"group:flame"}})
nodecore.register_cook_abm({nodenames = {modname .. ":cobble_hot"}})
----------------------------------------------------------------------
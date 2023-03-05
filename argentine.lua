-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
------------------------------------------------------------------------
local cob = ""
local loose = ""
for i = 0, 31 do
	cob = cob .. ":0," .. (i * 16) .. "=" ..modname.. "_bricks.png"
	loose = loose .. ":0," .. (i * 16) .. "=nc_api_loose.png"
end
local function tile(suff)
	return {
		name = "[combine:16x512:0,0=" ..modname.. ".png" .. cob .. suff,
		animation = {
			["type"] = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 8
		}
	}
end
-- ================================================================== --
minetest.register_node(modname .. ":bricks", {
		description = ("Argent Cloudstone Bricks"),
		tiles = {tile("")},
		groups = {
			argent = 1,
			stone_bricks = 1,
			bonded = 1,
			lux_absorb = 42,
			nc_door_scuff_opacity = 24
		},
		crush_damage = 4,
		sounds = nodecore.sounds("nc_terrain_stony")
})
------------------------------------------------------------------------
minetest.register_abm({
			label = "mercuriate bonded cloudstone bricks",
			nodenames = {"nc_stonework:bricks_cloudstone_bonded"},
			neighbors = {"group:quicksilver"},
			neighbors_invert = true,
			interval = 2,
			chance = 2,
			action = function(pos)
				nodecore.set_loud(pos, {name = modname .. ":bricks"})
				nodecore.witness(pos, {
						"mercuriate bonded cloudstone bricks"
					})
			end
		})

------------------------------------------------------------------------
nodecore.register_craft({
			label = "unbond argent bricks",
			action = "pummel",
			toolgroups = {cracky = 5},
--			duration = ,
			indexkeys = {modname .. ":bricks"},
			nodes = {
				{
					match = modname .. ":bricks",
					replace = "nc_stonework:bricks_cloudstone"
				}
			}
		})
-- ================================================================== --
local palode = modname.. ":palode"
local lodecube = "nc_lode:block_annealed"
local lodef = nodecore.underride({
	description = "Pale Lode",
	tiles = {"nc_lode_annealed.png^[colorize:ivory:32"},
	groups = {argent = 1, palode = 1, damage_radiant = 1}
}, minetest.registered_items[lodecube] or {})
minetest.register_node(palode, lodef)
------------------------------------------------------------------------
nodecore.register_craft({
		label = "heat palode",
		action = "cook",
		touchgroups = {flame = 3},
		neargroups = {coolant = 0},
		duration = 30,
		cookfx = true,
		indexkeys = {modname.. ":palode"},
		nodes = {{	match = {modname.. ":palode"},replace = "nc_lode:block_hot"}}
	})
nodecore.register_craft({
		label = "palode stack heating",
		action = "cook",
		touchgroups = {flame = 3},
		neargroups = {coolant = 0},
		duration = 30,
		cookfx = true,
		nodes = {{match = {modname.. ":palode", count = false}}},
		after = function(pos) return replacestack(pos, "nc_lode:block_hot") end
	})
nodecore.register_cook_abm({nodenames = {"group:palode"}, neighbors = {"group:flame"}})
------------------------------------------------------------------------
minetest.register_abm({
			label = "oxidize lode cube with quicksilver",
			nodenames = {"group:lode_cube"},
			neighbors = {"group:quicksilver"},
			neighbors_invert = true,
			interval = 120,
			chance = 10,
			action = function(pos)
				nodecore.set_node(pos, {name = modname .. ":palode"})
				nodecore.witness(pos, {
						"oxidize lode cube with quicksilver"
					})
			end
		})

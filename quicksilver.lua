-- LUALOCALS < ---------------------------------------------------------
local math, minetest, core, nodecore, nc
    = math, minetest, core, nodecore, nc
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------
local modname = core.get_current_modname()
local get_node = core.get_node
local set_node = core.swap_node
---------------------------------------------------------
local function anim(name, len)
	return {
		name = name,
		animation = {
			["type"] = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = len
		}
	}
end
---------------------------------------------------------
local stabletxr = anim(modname.. ".png", 8)
local flowtxr = anim(modname.. "_flow.png", 8)
---------------------------------------------------------
local quickdef = {
	description = "Quicksilver",
	drawtype = "liquid",
	tiles = {stabletxr},
	special_tiles = {flowtxr, flowtxr},
	paramtype = "light",
	liquid_viscosity = 5,
	liquid_renewable = false,
	liquid_range = 3,
	walkable = false,
	buildable_to = false,
	drowning = 2,
--	damage_per_second = 1,
--	drop = "",
	groups = {
		snappy = 1,
		quicksilver = 1,
	--	damage_touch = 1,
	--	damage_radiant = 1
	},
	post_effect_color = {a = 240, r = 75, g = 110, b = 110},
	liquid_alternative_flowing = modname .. ":quicksilver_flowing",
	liquid_alternative_source = modname .. ":quicksilver_source",
	sounds = nc.sounds("nc_terrain_bubbly")
}
---------------------------------------------------------
core.register_node(modname .. ":quicksilver_source",
	nc.underride({
			liquidtype = "source"
		}, quickdef))

core.register_node(modname .. ":quicksilver_flowing",
	nc.underride({
			liquidtype = "flowing",
			drawtype = "flowingliquid",
			paramtype2 = "flowingliquid"
		}, quickdef))

core.register_node(modname .. ":slowsilver", {
		description = "Slowsilver",
		tiles = {stabletxr},
		groups = {
			quicksilver = 1,
			snappy = 1,
			scaling_time = 500
		},
		paramtype = "light",
		sounds = nc.sounds("nc_lode_tempered")
	})
---------------------------------------------------------
local solid = modname .. ":slowsilver"
local src = modname.. ":quicksilver_source"
---------------------------------------------------------
nc.register_fluidwandering(
	"quicksilver",
	{src},
	4, --this is the interval
	function(pos, _, gen)
		if gen < 16 or math_random(1, 2) == 1 then return end
		core.set_node(pos, {name = modname .. ":slowsilver"})
		nc.dynamic_shade_add(pos, 1)
		return true
	end
)
---------------------------------------------------------
core.register_abm({
		label = "quicksilver quench",
		interval = 1,
		chance = 2,
		nodenames = {src},
		neighbors = {"group:coolant"},
		action = function(pos)
			nc.sound_play("nc_api_craft_hiss", {gain = 0.1, pos = pos})
			nc.smokeburst(pos)
			nc.dynamic_shade_add(pos, 1)
			return core.set_node(pos, {name = solid})
		end
	})

core.register_abm({
		label = "slowsilver melt",
		interval = 12,
		chance = 2,
		nodenames = {solid},
		arealoaded = 1,
		action = function(pos)
			if nc.quenched(pos) then return end
			return nc.set_loud(pos, {name = src})
		end
	})

nc.register_aism({
		label = "slowsilver stack melt",
		interval = 12,
		chance = 2,
		arealoaded = 1,
		itemnames = {solid},
		action = function(stack, data)
			if nc.quenched(data.pos) then return end
			if stack:get_count() == 1 and data.node then
				local def = core.registered_nodes[data.node.name]
				if def and def.groups and def.groups.is_stack_only then
					nc.set_loud(data.pos, {name = src})
					stack:take_item(1)
					return stack
				end
			end
			for rel in nc.settlescan() do
				local p = vector.add(data.pos, rel)
				if nc.buildable_to(p) then
					nc.set_loud(p, {name = src})
					stack:take_item(1)
					return stack
				end
			end
		end
	})

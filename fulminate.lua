-- LUALOCALS < ---------------------------------------------------------
local minetest, core, nodecore, nc, math, string, tonumber, pairs, vector
    = minetest, core, nodecore, nc, math, string, tonumber, pairs, vector
local math_ceil, math_log, math_random, string_sub
    = math.ceil, math.log, math.random, string.sub
-- LUALOCALS > ---------------------------------------------------------
local modname = core.get_current_modname()
local checkdirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 1, z = 0}
}
----------------------------------------------------------------------
nc.flare_life_base = 60
function nc.get_flare_expire(meta, name)
	local expire = meta:get_float("expire") or 0
	if expire > 0 then return expire end
	local ttl = nc.flare_life_base
	* (nc.boxmuller() * 0.1 + 1)
	if name then
		local id = tonumber(string_sub(name, -1))
		if id and id > 1 then
			ttl = ttl * 0.5 ^ (id - 1)
		end
	end
	expire = nc.gametime + ttl
	meta:set_float("expire", expire)
	return expire, true
end
----------------------------------------------------------------------
local mercury = modname.. ".png^[verticalframe:32:8"

local salts = "((" ..mercury.. ")^(nc_fire_ash.png^[opacity:80))^[colorize:ivory:60"
local saltlump = "(" ..salts.. ")^[mask:nc_fire_lump.png"
-- ================================================================ --
core.register_craftitem(modname .. ":lump_salt", {
		description = "Salt Lump",
		inventory_image = saltlump,
		groups = {flammable = 1},
		sounds = nc.sounds("nc_terrain_crunchy")
	})
----------------------------------------------------------------------
nc.register_craft({
		label = "scrape pale lode",
		action = "pummel",
		indexkeys = {modname.. ":palode"},
		nodes = {
			{match = modname.. ":palode", replace = "nc_lode:block_annealed"}
		},
		items = {
			{name = modname .. ":lump_salt", count = 1, scatter = 3}
		},
		toolgroups = {choppy = 3},
		itemscatter = 3
	})
----------------------------------------------------------------------

----------------------------------------------------------------------
core.register_node(modname .. ":salt_block", {
		description = "Mercury Fulminate",
		tiles = {salts},
		groups = {
			falling_node = 1,
			falling_repose = 1,
			crumbly = 1,
			flammable = 2
		},
		crush_damage = 0.25,
		damage_per_second = 1,
		sounds = nc.sounds("nc_terrain_swishy"),
		visinv_bulk_optimize = true,
		on_ignite = function(pos, node)
			core.set_node(pos, {name = modname.. ":fulmination"})
			nc.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
			if node and node.count and node.count > 1 then
				nc.item_disperse(pos, node.name, node.count - 1)
			end
			return true
		end
	})
----------------------------------------------------------------------
core.register_node(modname .. ":fulmination", {
		description = "Fulmination",
		tiles = {salts.. "^(nc_fire_ember_2.png^[invert:rgb)"},
		groups = {
			ember = 8,
			fulminate = 3,
			falling_node = 1,
			falling_repose = 1,
			crumbly = 1,
			stack_as_node = 1,
			igniter = 10,
			damage_touch = 1,
			damage_radiant = 6,
			flame_ambiance = 1
		},
		stack_max = 1,
		light_source = 14,
		crush_damage = 0.25,
		sounds = nc.sounds("nc_terrain_swishy"),
		visinv_bulk_optimize = true
	})
----------------------------------------------------------------------
nc.register_craft({
	label = "compress salt block",
	action = "pummel",
	toolgroups = {thumpy = 1},
	indexkeys = {modname .. ":lump_salt"},
	nodes = {
		{
			match = {name = modname .. ":lump_salt", count = 8},
			replace = modname .. ":salt_block"
		}
	}
})
------------------------------------------------------------------------
nc.register_craft({
	label = "break salt apart",
	action = "pummel",
	indexkeys = {modname.. ":salt_block"},
	nodes = {
		{match = modname.. ":salt_block", replace = "air"}
	},
	items = {
		{name = modname.. ":lump_salt", count = 8, scatter = 3},
	},
	toolgroups = {crumbly = 2},
	itemscatter = 3
})
-- ================================================================ --
core.register_node(modname .. ":flare", {
		description = "Flare",
		drawtype = "mesh",
		mesh = "nc_torch_torch.obj",
		tiles = {
			salts,
			"nc_tree_tree_top.png",
			salts.. "^[lowpart:50:nc_tree_tree_side.png",
			"[combine:1x1"
		},
		backface_culling = true,
		use_texture_alpha = "clip",
		selection_box = nc.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
		collision_box = nc.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
		paramtype = "light",
		sunlight_propagates = true,
		groups = {
			snappy = 1,
			falling_repose = 1,
			flammable = 1,
			firestick = 3,
			stack_as_node = 1
		},
		sounds = nc.sounds("nc_tree_sticky"),
		on_ignite = function(pos, node)
			core.set_node(pos, {name = modname.. ":flare_lit"})
			nc.get_flare_expire(core.get_meta(pos))
			nc.sound_play("nc_fire_ignite", {gain = 1, pos = pos})
			if node and node.count and node.count > 1 then
				nc.item_disperse(pos, node.name, node.count - 1)
			end
			return true
		end
	})
nc.register_craft({
		label = "assemble flare",
		normal = {y = 1},
		indexkeys = {modname.. ":lump_salt"},
		nodes = {
			{match = modname.. ":lump_salt", replace = "air"},
			{y = -1, match = "nc_torch:torch", replace = modname .. ":flare"},
		}
	})

nc.flare_life_stages = 3
for i = 1, nc.flare_life_stages do
	local alpha = (i - 1) * (256 / nc.flare_life_stages)
	if alpha > 255 then alpha = 255 end
	local txr = "nc_fire_coal_4.png^nc_fire_ember_4.png^(nc_fire_ash.png^[opacity:"
	.. alpha .. ")"
	core.register_node(modname .. ":flare_lit_" .. i, {
			description = "Lit Flare",
			drawtype = "mesh",
			mesh = "nc_torch_torch.obj",
			tiles = {
				txr,
				"nc_tree_tree_top.png",
				txr .. "^[lowpart:50:nc_tree_tree_side.png",
				{
					name = "nc_torch_flame.png^[colorize:cyan:100",
					animation = {
						["type"] = "vertical_frames",
						aspect_w = 3,
						aspect_h = 8,
						length = 0.4
					}
				}
			},
			backface_culling = true,
			use_texture_alpha = "clip",
			selection_box = nc.fixedbox(-1/8, -0.5, -1/8, 1/8, 0.5, 1/8),
			collision_box = nc.fixedbox(-1/16, -0.5, -1/16, 1/16, 0.5, 1/16),
			paramtype = "light",
			sunlight_propagates = true,
			light_source = 15 - i,
			groups = {
				snappy = 1,
				falling_repose = 1,
				stack_as_node = 1,
				flare_lit = 1,
				fulminate = 1,
				flame_ambiance = 1
			},
			stack_max = 1,
			sounds = nc.sounds("nc_tree_sticky"),
			preserve_metadata = function(_, _, oldmeta, drops)
				drops[1]:get_meta():from_table({fields = oldmeta})
			end,
			after_place_node = function(pos, _, itemstack)
				core.get_meta(pos):from_table(itemstack:get_meta():to_table())
			end,
			node_dig_prediction = nc.dynamic_light_node(16 - i),
			after_destruct = function(pos)
				nc.dynamic_light_add(pos, 16 - i)
			end
		})
end
core.register_alias(modname .. ":flare_lit", modname .. ":flare_lit_1")
------------------------------------------------------------------------
core.register_abm({
		label = "flare ignite",
		interval = 2,
		chance = 1,
		nodenames = {"group:flare_lit"},
		neighbors = {"group:flammable"},
		action_delay = true,
		action = function(pos)
			for _, ofst in pairs(checkdirs) do
				local npos = vector.add(pos, ofst)
				local nbr = core.get_node(npos)
				if core.get_item_group(nbr.name, "flammable") > 0
				and not nc.quenched(npos) then
					nc.fire_check_ignite(npos, nbr)
				end
			end
		end
	})
------------------------------------------------------------------------
local log2 = math_log(2)
local function flarelife(expire, pos)
	local max = nc.flare_life_stages
	if expire <= nc.gametime then return max end
	local life = (expire - nc.gametime) / nc.flare_life_base
	if life > 1 then return 1 end
	local stage = 1 - math_ceil(math_log(life) / log2)
	if stage < 1 then return 1 end
	if stage > max then return max end
	if pos and (stage >= 2) then
		nc.smokefx(pos, {
				time = 1,
				rate = (stage - 1) / 2,
				scale = 0.25
			})
	end
	return stage
end

local function snufffx(pos)
	nc.smokeburst(pos, 3)
	return nc.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
end
------------------------------------------------------------------------
core.register_abm({
		label = "flare snuff",
		interval = 1,
		chance = 1,
		nodenames = {"group:flare_lit"},
		action = function(pos, node)
			local expire = nc.get_flare_expire(core.get_meta(pos), node.name)
			if nc.quenched(pos) or nc.gametime > expire then
				core.remove_node(pos)
				core.add_item(pos, {name = "nc_fire:lump_ash"})
				snufffx(pos)
				return
			end
			local nn = modname .. ":flare_lit_" .. flarelife(expire, pos)
			if node.name ~= nn then
				node.name = nn
				return core.swap_node(pos, node)
			end
		end
	})
------------------------------------------------------------------------
nc.register_aism({
		label = "flare stack interact",
		itemnames = {"group:flare_lit"},
		action = function(stack, data)
			local pos = data.pos
			local player = data.player
			local wield
			if player and data.list == "main"
			and player:get_wield_index() == data.slot then
				wield = true
				pos = vector.add(pos, vector.multiply(player:get_look_dir(), 0.5))
			end

			local expire, dirty = nc.get_flare_expire(stack:get_meta(), stack:get_name())
			if (expire < nc.gametime)
			or nc.quenched(pos, data.node and 1 or 0.3) then
				snufffx(pos)
				return "nc_fire:lump_ash"
			end

			if wield and math_random() < 0.1 then nc.fire_check_ignite(pos) end

			local nn = modname .. ":flare_lit_" .. flarelife(expire, pos)
			if stack:get_name() ~= nn then
				stack:set_name(nn)
				return stack
			elseif dirty then
				return stack
			end
		end
	})
-- ================================================================ --
local txr_sides = "(nc_lode_annealed.png^[mask:nc_tote_sides.png)"
local txr_handle = "(nc_lode_annealed.png^nc_tote_knurl.png)"
local txr_top = txr_handle .. "^[transformFX^[mask:nc_tote_top.png^[transformR90^" .. txr_sides
----------------------------------------------------------------------
core.register_node(modname .. ":lamp", {
			description = "Lantern",
			drawtype = "mesh",
			visual_scale = nc.z_fight_ratio,
			mesh = "nc_tote_handle.obj",
			paramtype = "light",
			paramtype2 = "facedir",
			tiles = {
				txr_sides,
				txr_sides,
				txr_top,
				txr_handle,
				"nc_optics_glass_frost.png^(nc_lux_base.png^[opacity:252)"
			},
			backface_culling = true,
			use_texture_alpha = "clip",
			groups = {
				fulminate = 2, 
				snappy = 1,
				lux_emit = 20,
				stack_as_node = 1,
				falling_node = 1,
			},
			stack_max = 1,
			light_source = 14,
			sounds = nc.sounds("nc_lode_annealed")
		})
----------------------------------------------------------------------
local rfcall = function(pos, data)
	local ref = core.get_player_by_name(data.pname)
	local wield = ref:get_wielded_item()
	wield:take_item(1)
	ref:set_wielded_item(wield)
end

nc.register_craft({
		label = "fulminate lantern",
		action = "pummel",
		wield = {name = modname.. ":lump_salt"},
		after = rfcall,
		nodes = {
				{match = "nc_lantern:lamp7",
				replace = modname .. ":lamp"}
			}
	})
-- ================================================================ --
nc.register_abm({
		label = "Lantern Fulmination",
		interval = 60,
		chance = 10,
		nodenames = {modname .. ":lamp"},
		action = function(pos)
			nc.sound_play(modname.. "_explode", {gain = 4, pos = pos})
			nc.item_eject(pos, "nc_lode:bar_annealed", 8, 8)
			nc.item_eject(pos, "nc_lux:flux_source", 8, 8)
			return core.set_node(pos, {name = "air"})
		end
	})
nc.register_aism({
		label = "Held Lantern Fulmination",
		interval = 60,
		chance = 10,
		itemnames = {modname .. ":lamp"},
		action = function(stack, data)
			nc.sound_play(modname.. "_explode", {gain = 4})
			nc.item_eject(data.pos, "nc_lode:bar_annealed", 8, 8)
			nc.item_eject(data.pos, "nc_lux:flux_source", 8, 8)
			stack:set_name("")
			return stack
		end
	})
-- ================================================================ --
nc.register_abm({
		label = "effect:fulmination",
		interval = 1,
		chance = 1,
		nodenames = {"group:fulminate"},
		action = function(pos)
			nc.firestick_spark_ignite(pos)
			nc.sound_play(modname.. "_crackle", {gain = 0.4, pos = pos})
	end
})
nc.register_aism({
		label = "effect:held fulmination",
		interval = 1,
		chance = 1,
		itemnames = {"group:fulminate"},
		action = function(stack, data)
			nc.sound_play(modname.. "_crackle", {gain = 0.4, pos = data.pos})
			nc.firestick_spark_ignite(data.pos, data.player or data.obj, stack)
		end
	})

----------------------------------------------------------------------

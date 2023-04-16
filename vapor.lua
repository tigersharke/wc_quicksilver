-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, ipairs
    = math, minetest, nodecore, pairs, ipairs
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()
local get_node = minetest.get_node
local set_node = minetest.swap_node
local directions = {
	{x=1, y=0, z=0},
	{x=-1, y=0, z=0},
	{x=0, y=0, z=1},
	{x=0, y=0, z=-1},
}
local vapor = {name = modname.. ":vapor"}
local vaptxr = "(" ..modname.. ".png^[verticalframe:32:8)^[opacity:100"
---------------------------------------------------------
minetest.register_node(modname ..":vapor", {
		description = "Mercurial Vapor",
		tiles = {vaptxr},
		use_texture_alpha = "blend",
		drawtype = "allfaces",
		drowning = 2,
		damage_per_second = 8,
		paramtype = "light",
		sunlight_propagates = true,
		floodable = false,
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		touchthru = true,
		groups = {
           	qsvapor = 1,
           	vapor = 1
		},
		post_effect_color = {a = 100, r = 100, g = 150, b = 150}
	})

---------------------------------------------------------
----- ----- Lighter Than Air ----- -----
nodecore.register_abm({
     label = "qsvapor:lighter than air",
     nodenames = {"group:qsvapor"},
     interval = 1,
     chance = 2,
     action = function(pos, node)
          local next_pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local next_node = minetest.get_node(next_pos)
			if next_node.name == "air" then
				minetest.swap_node(next_pos, vapor)
				minetest.swap_node(pos, next_node)
			else 
			     local dir = directions[math.random(1,4)]
				local next_pos = vector.add(pos, dir)
				local next_node = minetest.get_node(next_pos)	
				     if next_node.name == "air" then
				          minetest.swap_node(next_pos, vapor)
				          minetest.swap_node(pos, next_node)
               end
          end
     end,
})
----- ----- Lighter Than Water ----- -----
nodecore.register_abm({
     label = "qsvapor:lighter than water",
     nodenames = {"group:qsvapor"},
     interval = 2,
     chance = 1,
     action = function(pos, node)
          local next_pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local next_node = minetest.get_node(next_pos)
			if next_node.name == "nc_terrain:water_flowing" then
				minetest.swap_node(next_pos, vapor)
				minetest.swap_node(pos, next_node)
			else 
			if next_node.name == modname.. ":quicksilver_flowing" then
				minetest.swap_node(next_pos, vapor)
				minetest.swap_node(pos, next_node)
			else 
			     local dir = directions[math.random(1,4)]
				local next_pos = vector.add(pos, dir)
				local next_node = minetest.get_node(next_pos)	
				     if next_node.name == "nc_terrain:water_flowing" then
				          minetest.swap_node(next_pos, vapor)
				          minetest.swap_node(pos, next_node)
               end
          end
	end
end,
})

nodecore.register_abm({
     label = "qsvapor:lighter than water source",
     nodenames = {"group:qsvapor"},
     interval = 2,
     chance = 1,
     action = function(pos, node)
          local next_pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local next_node = minetest.get_node(next_pos)
			if next_node.name == "nc_terrain:water_source" then
				minetest.swap_node(next_pos, vapor)
				minetest.swap_node(pos, next_node)
			else 
			if next_node.name == modname.. ":quicksilver_source" then
				minetest.swap_node(next_pos, vapor)
				minetest.swap_node(pos, next_node)
			else 
			     local dir = directions[math.random(1,4)]
				local next_pos = vector.add(pos, dir)
				local next_node = minetest.get_node(next_pos)	
				     if next_node.name == "nc_terrain:water_source" then
				          minetest.swap_node(next_pos, vapor)
				          minetest.swap_node(pos, next_node)
               end
          end
	end
end,
})

----- ----- Gaseous Dissapation ----- -----
nodecore.register_abm({
		label = "qsvapor:dissapation",
		interval = 10,
		chance = 10,
		nodenames = {modname .. ":vapor"},
		action = function(pos, node)
          local pressure = #nodecore.find_nodes_around(pos, "group:vapor")
          local airway = #nodecore.find_nodes_around(pos, "air")
               if pressure < 4 and airway > 2 then
		     nodecore.set_node(pos, {name = "air"})
          end
	end	
})

nodecore.register_abm({
		label = "thin atmoshpere",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":vapor"},
		action = function(pos, node)
		local altitude = pos.y
               if altitude > 120 and airway > 1 then
		     nodecore.set_node(pos, {name = "air"})
          end
	end	
})

---------------------------------------------------------
-------------------- Vapor Condensation --------------------
nodecore.register_limited_abm({
		label = "condense vapor",
		interval = 1,
		chance = 1,
		nodenames = {modname.. ":vapor"},
		action = function(pos, node)
          local pressure = #nodecore.find_nodes_around(pos, "group:qsvapor") --26 possible
          local airway = #nodecore.find_nodes_around(pos, "air") --26 possible
               if pressure > 8 and airway < 8 then
		     nodecore.set_node(pos, {name = modname .. ":quicksilver_source"})
		     nodecore.sound_play("nc_api_craft_hiss", {pos = pos, gain = 0.02, fade = 1})
		end
	end	
})




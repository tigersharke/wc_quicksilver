-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------
local modname = minetest.get_current_modname()

local cinnastone = "nc_terrain_stone.png^(nc_terrain_stone_hard.png^[opacity:50)"

local cob = ""
local loose = ""
for i = 0, 31 do
	cob = cob .. ":0," .. (i * 16) .. "=nc_terrain_cobble.png"
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

-- ================================================== --
minetest.register_node(modname .. ":cinnabar", {
		description = ("Cinnabar"),
		tiles = {cinnastone},
		color = "coral",
		groups = {
			stone = 1,
			cinnabar = 1,
			cracky = 4,
		},
		sounds = nodecore.sounds("nc_terrain_stony"),
		drop_in_place = modname.. ":cobble"
})

-- ================================================== --

minetest.register_node(modname .. ":cobble", {
		description = ("Cinnabar Cobble"),
		tiles = {tile("")},
		color = "coral",
		groups = {
			cinnabar_cobble = 1,
			cinnabar = 1,
			cracky = 3
		},
		sounds = nodecore.sounds("nc_terrain_stony"),
		alternate_loose = {
			tiles = {tile(loose)},
			repack_level = 2,
			groups = {
				cracky = 0,
				crumbly = 3,
				falling_repose = 2
			},
		sounds = nodecore.sounds("nc_terrain_chompy")		
	}
})

-- ================================================== --

minetest.register_node(modname .. ":cobble_hot", {
		description = ("Inhibited Quicksilver"),
		tiles = {tile("")},
		paramtype = "light",
		light_source = 3,
		stack_max = 1,
		groups = {
			cracky = 3,
			cinnabar = 1,
			cobbley = 1,
			cin_react = 1,
			stack_as_node = 1,
			damage_touch = 1,
			damage_radiant = 1
		},
		sounds = nodecore.sounds("nc_terrain_stony"),
		stack_max = 1
})

-- ================================================== --

minetest.register_ore({
	ore_type = "puff",
	ore = modname.. ":cinnabar",
	wherein = {"group:stone"},
	clust_scarcity = 94*32*94,
	clust_num_ores = 3,
	clust_size = 8,
	y_min = -31000,
	y_max = -128,
	noise_threshold = 0.75,
    -- If noise is above this threshold, ore is placed. Not needed for a
    -- uniform distribution.

    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 21,
        octaves = 3,
        persistence = 0.7,
    },
     -- puff
    np_puff_top = {
        offset = 4,
        scale = 2,
        spread = {x = 100, y = 100, z = 100},
        seed = 42,
        octaves = 3,
        persistence = 0.7
    },
    np_puff_bottom = {
        offset = 4,
        scale = 2,
        spread = {x = 100, y = 100, z = 100},
        seed = 13,
        octaves = 3,
        persistence = 0.7
    }
})

-- ================================================== --

-- Load support for MT game translation.
local S = minetest.get_translator("st_core")
local mod_path = minetest.get_modpath("st_core")

dofile(mod_path.."/weapon.lua")
dofile(mod_path.."/building.lua")
dofile(mod_path.."/mapgen.lua")
dofile(mod_path.."/enemy.lua")


local function sign(x)
	return (x<0 and -1) or 1
end

minetest.register_entity("st_core:asteroid", {
	-- Entity properties
	hp_max = 10,
	physical = true,
	weight = 5,
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	visual = "cube",
	visual_size = {x=1, y=1},
	textures = {"asteroid.png", "asteroid.png", "asteroid.png", "asteroid.png", "asteroid.png", "asteroid.png"},

	on_activate = function(self, staticdata)
		-- Calculate a random velocity vector
		local pos = self.object:get_pos()
		local velocity = {
			x = math.random(-4, 4),
			y = math.random(-4, 4),
			z = math.random(-4, 4),
		}

		velocity = vector.normalize(velocity)
		local rnd = math.random(1, 2)
		velocity = {x = velocity.x * rnd, y = velocity.y * rnd, z = velocity.z * rnd}

		-- Set the entity's velocity
		self.object:set_velocity(velocity)

		--local size = math.random(0.5, 2)
		--local hsize = size / 2;
	   	--self.object:set_properties({
		--   visual_size = {x=size, y=size},
		--   collisionbox = {-hsize,-hsize,-hsize,hsize,hsize,hsize},
	   	--})
	end,

	-- Entity functions
	on_step = function(self, dtime)

	end,

	on_death = function(self, puncher)
		if self.object:get_luaentity().name == "st_core:asteroid" then
			local owner_name = puncher:get_luaentity() and puncher:get_luaentity().owner
			if owner_name then
				local counter = tonumber(minetest.get_player_by_name(owner_name):get_meta():get_string("asteroid_count")) or 0
				counter = counter + 1
				minetest.get_player_by_name(owner_name):get_meta():set_string("asteroid_count", tostring(counter))
			end
		end
	end
})

local function get_entities_in_radius(pos, radius, entity_name)
	local objects = minetest.get_objects_inside_radius(pos, radius)
	local entities = {}

	-- Loop through the list of objects and add entities of the specified type to the result table
	for _, object in ipairs(objects) do
	   if object:get_luaentity() and object:get_luaentity().name == entity_name then
		  table.insert(entities, object)
	   end
	end

	return entities
end

minetest.register_abm({
	label = "Spawn Asteroid",
	nodenames = {"air"},
	neighbors = {},
	interval = 1,
	chance = 100000,
	action = function(pos)
		if #get_entities_in_radius(pos, 100, "st_core:asteroid") < 50 then
			minetest.add_entity(pos, "st_core:asteroid")
		end
	end,
})

local function prepare()
	minetest.log("action", "[core] Preparing Level...")

	minetest.set_node({x=0, y=0, z=0}, {name="st_nodes:base_metall"})
	minetest.set_node({x=0, y=-1, z=0}, {name="st_nodes:base_metall"})
	minetest.set_node({x=1, y=0, z=0}, {name="st_nodes:base_metall"})
	minetest.set_node({x=1, y=1, z=0}, {name="st_nodes:turret"})
	minetest.set_node({x=0, y=0, z=1}, {name="st_nodes:base_metall"})
	minetest.set_node({x=-1, y=0, z=0}, {name="st_nodes:base_metall"})
	minetest.set_node({x=0, y=0, z=-1}, {name="st_nodes:base_metall"})
	minetest.set_node({x=0, y=1, z=0}, {name="st_nodes:energy_core"})
end

local function show_popup(player, pos, text, duration)
    local id = player:hud_add({
        hud_elem_type = "text",
        position = {x = 0.5, y = 0.5},
        text = text,
        alignment = {x = 0, y = 0},
        offset = {x = pos.x, y = pos.y + 1, z = pos.z},
        size = {x = 1, y = 1},
        number = 0xFF0000,
        z_index = 10000,
    })

    minetest.after(duration, function()
        player:hud_remove(id)
    end)
end


minetest.register_on_joinplayer(function(player, last_login)
	minetest.set_player_privs(player:get_player_name(), {interact=true, shout=true, fly=true})
	player:override_day_night_ratio(1)
	player:set_physics_override({gravity = 0, speed=2})
	local formspec ="size[15,15]" ..
					"position[0.55,0.55]" ..
					"image[0,0;15,15;textbox.png]" ..
					"bgcolor[#00000000]" ..
					"label[5,1;How to play:]" ..
					"label[1.5,2;The game is all about energy. If you run out of energy, you die.]" ..
					"label[1.5,3;Energy is lost when getting attacked or when attacking.]" ..
					"label[1.5,4;In level 1 you will loose energy even when doing nothing]" ..
					"label[1.5,5;You can recharge energy near an energy core.]" ..
					"label[1.5,6;You can mine asteroids by shooting at them.]" ..
					"label[1.5,7;Use mined asteroids to build structures.]" ..
					"label[1.5,8;Build research facilities to increase your level.]" ..
					"label[1.5,9;Higher levels will grant you improvements or unlock things]" ..
					"label[1.5,10;You get the fly privilege by default so be sure to turn fly mode on.]"
	player:set_inventory_formspec(formspec)
	player:hud_set_flags({hotbar = true, healthbar=false, crosshair=true, wielditem=false, breathbar=false})
	player:set_properties({
		mesh = "spaceship.obj",
		textures = {"spaceship.png"},
		visual = "mesh",
		visual_size = {x = 1, y = 1},
		collisionbox = {-0.25, -0.1, -0.25, 0.25, 0.1, 0.25},
		stepheight = 0.55,
		eye_height = 0.5,
		glow = 10,
		light_range = 14,
		light_intensity = 1.0,
	})
	player:set_sky({
		-- base_color = "#000000",
		type = "skybox",
		textures = {"space_edited.png", "space_edited.png", "space_edited.png", "space_edited.png", "space_edited.png", "space_edited.png"},
		clouds = false,
	})
	player:set_sun({
		visible = false,
		sunrise_visible = false,
	})
	player:set_moon({
		visible = false,
	})


	local item_names = {"st_core:projectile_launcher", "st_core:building_menu"}
	local inventory = player:get_inventory()
	--local hotbar_size = inventory:get_size("main")
	for i = 1, 9 do
		inventory:set_stack("main", i, ItemStack(item_names[i]))
	end


	local meta = player:get_meta()
	meta:set_int("research_facilities", meta:get_int("research_facilities") or 0)
	meta:set_int("science_level", meta:get_int("science_level") or 1)
	if meta:get_int("science_level") < 1 then
		meta:set_int("science_level", 1)
	end
	meta:set_float("science_progress", meta:get_float("science_progress") or 0)

	meta:set_int("max_energy", 100)
	meta:set_int("energy", 100)
	meta:set_int("asteroid_count", meta:get_int("asteroid_count") or 0)
	meta:set_int("energy_generation", meta:get_int("energy_generation") or -1)

	-- Add the energy hud:
	local energy_hud_id = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 1, y = 0},
		size = {x = 30, y = 30},
		text = "energy.png",
		number = player:get_meta():get_int("energy") / 10,
		direction = 0,
		alignment = {x = 1, y = 0},
		offset = {x = -150, y = 5},
	})

	-- Add the asteroid counter to the player's HUD
	local asteroid_hud_id = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0.0},
		size = {x = 1, y = 1},
		text = "",
		number = 0xFFFFFF,
		alignment = {x = 1, y = 0},
		offset = {x = -70, y = 75},
		name = "asteroid_counter",
	})
	player:hud_add({
		hud_elem_type = "image",
		position = {x = 1, y = 0},
		scale = {x = 2, y = 2},
		text = "asteroid.png",
		alignment     = {x=1, y=0},
		offset        = {x=-50, y=75},
		size          = {x=100, y=100},
		z_index       = 0,
	})

	-- Scientific Progress Bar:
	local bar_x = 0.5
	local bar_y = 0
	local bar_w = 4
	local bar_h = 4
	local progress = player:get_meta():get_float("science_progress") / 100
	local progress_bar_id = player:hud_add({
    	hud_elem_type = "image",
    	position      = {x=bar_x, y=bar_y},
    	text          = "sciencebar_progress.png",
    	offset        = {x=0, y=40},
    	scale         = {x=bar_w * progress, y=bar_h},
	})
	player:hud_add({
    	hud_elem_type = "image",
    	position      = {x=bar_x, y=bar_y},
    	text          = "sciencebar.png",
		offset        = {x=0, y=40},
    	scale         = {x=bar_w, y=bar_h},
	})
	local level_hud_id = player:hud_add({
		hud_elem_type = "text",
		position = {x = bar_x, y = bar_y},
		size = {x = 1, y = 1},
		text = "0",
		number = 0xFFFFFF,
		offset = {x = 0, y = 40},
		name = "level",
	})

	minetest.register_globalstep(function(dtime)
		player:hud_change(energy_hud_id, "number", meta:get_int("energy") / 10)
		player:hud_change(asteroid_hud_id, "text", meta:get_int("asteroid_count"))
		player:hud_change(level_hud_id, "text", meta:get_int("science_level"))

		local progress = meta:get_float("science_progress") / 100
		player:hud_change(progress_bar_id, "scale", {x=bar_w * progress, y=bar_h})

		local energy = meta:get_int("energy") + meta:get_int("energy_generation")
		meta:set_int("energy", energy)
		if energy <= 0 then
			player:set_hp(0)
			meta:set_int("energy", 100)
		end

		local sp = meta:get_float("science_progress")
		local increase = (1 / meta:get_int("science_level")) * dtime
		local facilities = meta:get_int("research_facilities")
		sp = sp + (facilities * increase)
		meta:set_float("science_progress", sp)
		if sp >= 100. then
			meta:set_float("science_progress", 0.)
			local sl = meta:get_int("science_level") + 1
			meta:set_int("science_level", sl)

			if sl == 2 then
				meta:set_int("energy_generation", 0)
				show_popup(player, {x = 0.5, y = 0.5}, "Your natural energy generation increased from -1 to 0")
			end
			if sl == 3 then
				meta:set_int("energy_generation", 1)
				show_popup(player, {x = 0.5, y = 0.5}, "Your natural energy generation increased from 0 to 1")
			end
		end
	end)

	-- Prepare the Envoirement, this should only be done once on world creation
	local times = meta:get_int("times") or 0
	if times <= 0 then
		minetest.after(1, function()
  			prepare()
		end)
		meta:set_int("times", 1)
	end

	minetest.sound_play({name="simple_space"}, {gain = 1.0, loop=true})

end)

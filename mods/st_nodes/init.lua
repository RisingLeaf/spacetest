-- Define asteroid cost of the nodes
local BASE_METALL_COST = 1
local ENERGY_CORE_COST = 5
local RESEARCH_FACILITY_COST = 3
local TURRET_COST = 2


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---- BASE METALL
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

minetest.register_node("st_nodes:base_metall", {
	description = "Base Metall",
	tiles = {"base_metall.png"},
	groups = {cracky=3},

	can_place = function(itemstack, player, pointed_thing)
		local meta = player:get_meta()
		local asteroids = meta:get_int("asteroid_count") or 0

		if asteroids >= BASE_METALL_COST then
			meta:set_int("asteroid_count", asteroids - BASE_METALL_COST)

			return true
		else
			minetest.chat_send_player(player:get_player_name(), "You don't have enough asteroids to place this node. You need: "..BASE_METALL_COST)
			return false
		end
	end,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local node_pos = pointed_thing.above

		local player_name = placer:get_player_name()

		if not minetest.is_protected(node_pos, player_name) and minetest.registered_nodes["st_nodes:base_metall"].can_place(itemstack, placer, pointed_thing) then
			minetest.set_node(node_pos, {name="st_nodes:base_metall"})
			minetest.sound_play("default_place_node_hard", {pos=node_pos})
		end

		return itemstack
	end,
})

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---- ENERGY CORE
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

minetest.register_node("st_nodes:energy_core", {
	description = "Energy Core",
	drawtype = "mesh",
	mesh = "energy_core.obj",
	tiles = {"spaceship.png"},
	collisionbox = {-0.75, 0, -0.75, 0.75, 0.25, 0.75},
	groups = {cracky = 3},
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	sunlight_propagates = true,

	can_place = function(itemstack, player, pointed_thing)
		local meta = player:get_meta()
		local asteroids = meta:get_int("asteroid_count") or 0

		if asteroids >= ENERGY_CORE_COST then
			local pointed_node = minetest.get_node(pointed_thing.under)
			if pointed_node.name ~= "st_nodes:base_metall" then
				minetest.chat_send_player(player:get_player_name(), "You can only build this on top of base metall.")
				return false
			end
			meta:set_int("asteroid_count", asteroids - ENERGY_CORE_COST)

			return true
		else
			minetest.chat_send_player(player:get_player_name(), "You don't have enough asteroids to place this node. You need: "..ENERGY_CORE_COST)
			return false
		end
	end,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local node_pos = pointed_thing.above

		local player_name = placer:get_player_name()

		if not minetest.is_protected(node_pos, player_name) and minetest.registered_nodes["st_nodes:energy_core"].can_place(itemstack, placer, pointed_thing) then
			minetest.set_node(node_pos, {name="st_nodes:energy_core"})
			minetest.sound_play("default_place_node_hard", {pos=node_pos})
		end

		return itemstack
	end,
})
minetest.register_abm({
	label = "Recharge Player",
	nodenames = {"st_nodes:energy_core"},
	neighbors = {},
	interval = 1,
	chance = 1,
	action = function(pos)
		if pos ~= nil then
			local objs = minetest.get_objects_inside_radius(pos, 2)
			for _, obj in pairs(objs) do
				if obj:is_player() then
					local meta = obj:get_meta()
					if meta:get_int("energy") < meta:get_int("max_energy") then
						meta:set_int("energy", meta:get_int("energy") + 5)
						if meta:get_int("energy") > meta:get_int("max_energy") then
							meta:set_int("energy", meta:get_int("max_energy"))
						end
						local player_pos = obj:get_pos()
						local direction = vector.normalize(vector.subtract(player_pos, pos))
						minetest.add_particle({
							pos = pos,
							velocity = vector.multiply(direction, vector.length(player_pos - pos)),
							acceleration = {x = 0, y = 0, z = 0},
							expirationtime = 1,
							size = 1,
							collisiondetection = true,
							collision_removal = true,
							texture = "energy_recharge.png",
							glow = 10,
						})
					end
				end
			end
		end
	end,
})

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---- RESEARCH FACILITY
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

minetest.register_node("st_nodes:research_facility", {
	description = "Research Facility",
	drawtype = "mesh",
	mesh = "research_facility.obj",
	tiles = {"spaceship.png"},
	collisionbox = {-0.5, 0, -0.5, 0.5, 1.0, 0.5},
	groups = {cracky = 3},
	sunlight_propagates = true,

	can_place = function(itemstack, player, pointed_thing)
		local meta = player:get_meta()
		local asteroids = meta:get_int("asteroid_count") or 0

		if asteroids >= RESEARCH_FACILITY_COST then
			local pointed_node = minetest.get_node(pointed_thing.under)
			if pointed_node.name ~= "st_nodes:base_metall" then
				minetest.chat_send_player(player:get_player_name(), "You can only build this on top of base metall.")
				return false
			end

			meta:set_int("asteroid_count", asteroids - RESEARCH_FACILITY_COST)

			return true
		else
			minetest.chat_send_player(player:get_player_name(), "You don't have enough asteroids to place this node. You need: "..RESEARCH_FACILITY_COST)
			return false
		end
	end,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local node_pos = pointed_thing.above

		local player_name = placer:get_player_name()

		if not minetest.is_protected(node_pos, player_name) and minetest.registered_nodes["st_nodes:research_facility"].can_place(itemstack, placer, pointed_thing) then
			minetest.set_node(node_pos, {name="st_nodes:research_facility"})
			minetest.sound_play("default_place_node_hard", {pos=node_pos})

			local meta = placer:get_meta()
			meta:set_int("research_facilities", meta:get_int("research_facilities") + 1)
		end

		return itemstack
	end,

})

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---- TURRET
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

local function projectile_behavior(self, dtime)
	local pos = self.object:get_pos()
		if pos ~= nil then
			local objs = minetest.get_objects_inside_radius(pos, 1.0)
			for _, obj in ipairs(objs) do
				if obj:get_luaentity() and obj:get_luaentity().name ~= self.name then
					if not obj:is_player() then
						obj:punch(self.object, 1.0, {
							full_punch_interval = 1.0,
							damage_groups = {fleshy = 1},
						})

						self.object:remove()
					end
				end
			end
		end
end
minetest.register_entity("st_nodes:turret_projectile", {
	hp_max = 1,
	physical = false,
	weight = 0,
	collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
	visual = "sprite",
	textures = {"turret_projectile.png"},
	visual_size = {0.2, 0.2},
	on_activate = function(self, staticdata)
	end,
	on_step = projectile_behavior,
	on_collision = function(self, other, point)
	end,
})

minetest.register_node("st_nodes:turret", {
	description = "Turret",
	drawtype = "mesh",
	mesh = "turret.obj",
	tiles = {"spaceship.png"},
	collisionbox = {-0.5, 0, -0.5, 0.5, 1.0, 0.5},
	groups = {cracky = 3},
	sunlight_propagates = true,
	can_place = function(itemstack, player, pointed_thing)
		local meta = player:get_meta()
		local asteroids = meta:get_int("asteroid_count") or 0

		if asteroids >= TURRET_COST then
			local pointed_node = minetest.get_node(pointed_thing.under)
			if pointed_node.name ~= "st_nodes:base_metall" then
				minetest.chat_send_player(player:get_player_name(), "You can only build this on top of base metall.")
				return false
			end

			meta:set_int("asteroid_count", asteroids - TURRET_COST)

			return true
		else
			minetest.chat_send_player(player:get_player_name(), "You don't have enough asteroids to place this node. You need: "..TURRET_COST)
			return false
		end
	end,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local node_pos = pointed_thing.above

		local player_name = placer:get_player_name()

		if not minetest.is_protected(node_pos, player_name) and minetest.registered_nodes["st_nodes:turret"].can_place(itemstack, placer, pointed_thing) then
			minetest.set_node(node_pos, {name="st_nodes:turret"})
			minetest.sound_play("default_place_node_hard", {pos=node_pos})

		end

		return itemstack
	end,
})
minetest.register_abm({
	label = "Turret Auto Defense",
	nodenames = {"st_nodes:turret"},
	neighbors = {},
	interval = 1,
	chance = 1,
	action = function(pos)
		local objects = minetest.get_objects_inside_radius(pos, 10)
		for _, obj in ipairs(objects) do
			if obj:get_luaentity() ~= nil and obj:get_luaentity().name == "st_core:alien_ship" then
				local dir = vector.direction(pos, obj:get_pos())
				local projectile = minetest.add_entity(pos, "st_nodes:turret_projectile")
				local norm_dir = vector.normalize(dir)
				projectile:set_velocity({x = norm_dir.x * 10, y = norm_dir.y * 10, z = norm_dir.z * 10})
				return true
			end
		end
	end,
})

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---- ASTEROID
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

minetest.register_node("st_nodes:asteroid", {
	description = "Asteroid",
	tiles = {"asteroid.png"},
	groups = {cracky=3},
})
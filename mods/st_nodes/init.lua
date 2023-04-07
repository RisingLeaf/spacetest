-- Define asteroid cost of the node
local BASE_METALL_COST = 1

minetest.register_node("st_nodes:base_metall", {
	description = "Base Metall",
	tiles = {"base_metall.png"},
	groups = {cracky=3},

	-- Function to check if the player has enough asteroids to place the node
	can_place = function(itemstack, player, pointed_thing)
		local meta = player:get_meta()
		local asteroids = meta:get_int("asteroid_count") or 0

		-- Check if the player has enough asteroids to place the node
		if asteroids >= BASE_METALL_COST then
			-- Deduct the asteroid cost from the player's inventory
			meta:set_int("asteroid_count", asteroids - BASE_METALL_COST)

			return true -- Allow the player to place the node
		else
			-- Notify the player that they don't have enough asteroids to place the node
			minetest.chat_send_player(player:get_player_name(), "You don't have enough asteroids to place this node. You need: "..BASE_METALL_COST)
			return false -- Prevent the player from placing the node
		end
	end,

	-- Override on_place function to use can_place for asteroid check
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

local ENERGY_CORE_COST = 5

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

	-- Function to check if the player has enough asteroids to place the node
	can_place = function(itemstack, player, pointed_thing)
		local meta = player:get_meta()
		local asteroids = meta:get_int("asteroid_count") or 0

		-- Check if the player has enough asteroids to place the node
		if asteroids >= ENERGY_CORE_COST then
			-- Deduct the asteroid cost from the player's inventory
			meta:set_int("asteroid_count", asteroids - ENERGY_CORE_COST)

			return true -- Allow the player to place the node
		else
			-- Notify the player that they don't have enough asteroids to place the node
			minetest.chat_send_player(player:get_player_name(), "You don't have enough asteroids to place this node. You need: "..ENERGY_CORE_COST)
			return false -- Prevent the player from placing the node
		end
	end,

	-- Override on_place function to use can_place for asteroid check
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

minetest.register_node("st_nodes:asteroid", {
	description = "Asteroid",
	tiles = {"asteroid.png"},
	groups = {cracky=3},
})
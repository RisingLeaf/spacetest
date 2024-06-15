---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---- ASTEROID
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

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
		local rnd = math.random(1, 3)
		velocity = {x = velocity.x * rnd, y = velocity.y * rnd, z = velocity.z * rnd}

		self.object:set_velocity(velocity)

	end,

	on_step = function(self, dtime)
		-- Check for collision with players
		local pos = self.object:get_pos()
		local players = minetest.get_objects_inside_radius(pos, 1.0)
		for _, player in ipairs(players) do
			if player:is_player() then
				local meta = player:get_meta()
				meta:set_int("energy", meta:get_int("energy") - 5)
				self.object:remove()
			end
		end
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

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---- METEOR
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

minetest.register_entity("st_core:meteor", {
	hp_max = 10,
	physical = true,
	weight = 5,
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	visual = "cube",
	visual_size = {x=1, y=1},
	textures = {"meteor.png", "meteor.png", "meteor.png", "meteor.png", "meteor.png", "meteor.png"},

	-- Particle properties
	particle_texture = "fire_particle_",
	particle_size = 1,
	particle_lifetime = 10,

	on_activate = function(self, staticdata)
		local pos = self.object:get_pos()
		local velocity = {
			x = math.random(-10, 10),
			y = math.random(-10, 10),
			z = math.random(-10, 10),
		}

		velocity = vector.normalize(velocity)
		local rnd = math.random(8, 15)
		velocity = {x = velocity.x * rnd, y = velocity.y * rnd, z = velocity.z * rnd}

		self.object:set_velocity(velocity)
	end,

	on_step = function(self, dtime)
		local pos = self.object:get_pos()

		for i = 1, 15 do
			local r_pos = {
				x = math.random(-4, 4) / 8,
				y = math.random(-4, 4) / 8,
				z = math.random(-4, 4) / 8
			}
			local p_pos = vector.add(pos, r_pos)
			local particle = minetest.add_particle({
				pos = p_pos,
				expirationtime = math.random(5, self.particle_lifetime) / 10,
				size = self.particle_size,
				texture = self.particle_texture .. math.random(1,2) .. ".png"
			})
		end

		local objects = minetest.get_objects_inside_radius(pos, 1)
		for _, object in ipairs(objects) do
			if object:is_player() and not object:get_player_control().sneak then
				local meta = object:get_meta()
				meta:set_int("energy", meta:get_int("energy") - 20)
				self.object:remove()
			end
		end
	end,
})

minetest.register_abm({
	label = "Spawn Meteor",
	nodenames = {"air"},
	neighbors = {},
	interval = 5,
	chance = 700000,
	action = function(pos)
		if #get_entities_in_radius(pos, 200, "st_core:meteor") < 3 then
			minetest.add_entity(pos, "st_core:meteor")
		end
	end,
})

local function alien_behavior(self, dtime)
	if not self.target then
		local players = minetest.get_connected_players()
		local min_distance = math.huge
		local nearest_player = nil

		for _, player in ipairs(players) do
		  local distance = vector.distance(self.object:get_pos(), player:get_pos())
		  if distance < min_distance then
			min_distance = distance
			nearest_player = player
		  end
		end

		if nearest_player then
		  self.target = nearest_player
		end
	end

	if self.target and vector.distance(self.object:get_pos(), self.target:get_pos()) <= self.attack_range then
		if self.attack_timer <= 0 then
			local pos = self.object:get_pos()
			local dir = vector.direction(pos, self.target:get_pos())
			local projectile = minetest.add_entity(pos, "st_core:alien_projectile")
			local norm_dir = vector.normalize(dir)
			projectile:setvelocity({x = norm_dir.x * 10, y = norm_dir.y * 10, z = norm_dir.z * 10})
			projectile:get_luaentity().owner = self.object:get_luaentity()

			minetest.sound_play({name = "cannon"}, {pos=pos})

			self.attack_timer = self.attack_cooldown
		end
	else
		local pos = self.object:get_pos()
		local vel = vector.direction(pos, self.target:get_pos())
		vel = vector.multiply(vector.normalize(vel), self.max_speed)
		self.object:set_velocity(vel)

		self.object:set_yaw(math.atan2(-vel.x, vel.z))
	end

	self.attack_timer = self.attack_timer - dtime
end


minetest.register_entity("st_core:alien_ship", {
	initial_properties = {
		physical = true,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "mesh",
		mesh = "alien.obj",
		textures = {"alien.png"},
	},
	health = 10,
	attack_damage = 5,
	attack_cooldown = 1,
	attack_range = 10,
	max_speed = 5,
	on_step = alien_behavior,
	on_activate = function(self, staticdata)
		self.attack_timer = 10
		self.attack_cooldown = 2
	end,
})
local function get_entities_in_radius(pos, radius, entity_name)
	local objects = minetest.get_objects_inside_radius(pos, radius)
	local entities = {}

	for _, object in ipairs(objects) do
	   if object:get_luaentity() and object:get_luaentity().name == entity_name then
		  table.insert(entities, object)
	   end
	end

	return entities
end
minetest.register_abm({
	label = "Spawn Alien",
	nodenames = {"air"},
	neighbors = {},
	interval = 1,
	chance = 100000000,
	action = function(pos)
		local distance = vector.distance(pos, {x=0, y=0, z=0})
		if distance >= 25 and #get_entities_in_radius(pos, 100, "st_core:alien_ship") < 5 then
			minetest.add_entity(pos, "st_core:alien_ship")
		end
	end,
})

minetest.register_entity("st_core:alien_projectile", {
	hp_max = 1,
	physical = false,
	weight = 0,
	collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
	visual = "sprite",
	textures = {"enemy_projectile.png"},
	visual_size = {0.2, 0.2},

	on_activate = function(self, staticdata)
	end,

	on_step = function(self, dtime)
		self.timer = (self.timer or 0) + dtime
		if self.timer > 1 then
			self.object:remove()
		end


		local pos = self.object:get_pos()
		if pos ~= nil then
			local objs = minetest.get_objects_inside_radius(pos, 1.0)
			for _, obj in ipairs(objs) do
				if obj:is_player() then
					local meta = obj:get_meta()
					meta:set_int("energy", meta:get_int("energy") - 2)
					self.object:remove()
				end
			end
		end
	end,

	on_collision = function(self, other, point)
	end
})
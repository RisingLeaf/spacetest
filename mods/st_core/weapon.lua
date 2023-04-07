-- Define the projectile entity
minetest.register_entity("st_core:projectile", {
	-- Entity properties
	hp_max = 1,
	physical = false,
	weight = 0,
	collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
	visual = "sprite",
	textures = {"projectile_texture.png"},
	visual_size = {0.2, 0.2},

	on_activate = function(self, staticdata)
	end,

	-- Entity functions
	on_step = function(self, dtime)
		-- Remove the projectile after 1 second
		self.timer = (self.timer or 0) + dtime
		if self.timer > 1 then
			self.object:remove()
		end


		local pos = self.object:get_pos()
		if pos ~= nil then
			local objs = minetest.get_objects_inside_radius(pos, 1.0)
			for _, obj in ipairs(objs) do
				if obj:get_luaentity() and obj:get_luaentity().name ~= self.name then
					if not obj:is_player() then
						-- Inflict damage on the collided entity
						obj:punch(self.object, 1.0, {
							full_punch_interval = 1.0,
							damage_groups = {fleshy = 1},
						})

						-- Destroy the projectile entity
						self.object:remove()
					end
				end
			end
		end
	end,

	on_collision = function(self, other, point)
	end
})

-- Register the item
minetest.register_tool("st_core:projectile_launcher", {
	-- Item properties
	description = "Projectile Launcher",
	inventory_image = "cannon.png",

	-- Item functions
	on_use = function(itemstack, player, pointed_thing)
		-- Create and shoot the projectile
		meta = player:get_meta()

		if meta:get_int("energy") >= 5 then
			local pos = player:get_pos()
			local dir = player:get_look_dir()
			local projectile = minetest.add_entity(pos, "st_core:projectile")
			projectile:setvelocity(dir:multiply(20))
			projectile:get_luaentity().owner = player:get_player_name()

			meta:set_int("energy", meta:get_int("energy") - 5)
		end
		-- Play a shooting sound
		-- minetest.sound_play("my_shooting_sound", {pos = pos})
	end,
})
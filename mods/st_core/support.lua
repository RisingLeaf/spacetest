minetest.register_entity("st_core:drone", {
	on_activate = function(self, staticdata)
		self.object:set_properties({
			mesh = "spaceship.obj",
			textures = {"spaceship.png"},
			visual = "mesh",
			visual_size = {x = 1, y = 1},
			collisionbox = {-0.25, -0.1, -0.25, 0.25, 0.1, 0.25},
			physical = true,
		})
	end,

	on_step = function(self, dtime)
		local pos = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(pos, 10)
		for _, obj in ipairs(objs) do
			if obj:is_player() then
			elseif obj:get_luaentity() and obj:get_luaentity().name == "st_core:asteroid" then
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=1},
				})
			end
		end
	end,

	on_punch = function(self, puncher)
	end,
})
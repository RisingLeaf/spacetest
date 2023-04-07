minetest.register_node("st_nodes:base_metall", {
	description = "Base Metall",
	tiles = {"base_metall.png"},
	groups = {cracky=3}
})

minetest.register_node("st_nodes:energy_core", {
	description = "Energy Core",
	drawtype = "mesh",
	mesh = "energy_core.obj",
	tiles = {"spaceship.png"},
	collisionbox = {-0.75, 0, -0.75, 0.75, 0.25, 0.75},
	groups = {cracky = 3},
	paramtype = "light",
	sunlight_propagates = true,
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
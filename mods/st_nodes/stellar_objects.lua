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

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---- BLACK HOLE
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

minetest.register_node("st_nodes:black_hole", {
	description = "Black Hole",
	drawtype = "glasslike",
	paramtype = "light",
	tiles = {"black_hole.png"},
	groups = {cracky=3},
	--sounds = default.node_sound_glass_defaults(),
})

-- Define the function to calculate gravitational force on the player's ship
local function calculate_gravity(player, pos)
	local ship_pos = player:get_pos()
	local distance = vector.distance(ship_pos, pos)
	local gravity_force = math.max(distance - 2, 0) / 38
	gravity_force = (gravity_force - 1) * -1
	gravity_force = gravity_force * gravity_force * 100

	if distance < 2 then
		player:set_hp(0)
	end

	local direction = vector.direction(ship_pos, pos)
	local velocity = vector.multiply(direction, gravity_force)
	player:add_velocity(velocity)
end

-- Define the function to handle particle generation around black holes
local function generate_particles(pos)
	for i = 1, 100 do
		local r_pos = {
			x = math.random(-2, 2),
			y = math.random(-2, 2),
			z = math.random(-2, 2)
		}
		r_pos = vector.normalize(r_pos)
		local factor = math.random(2, 15)
		r_pos = { x = r_pos.x * factor, y = r_pos.y * factor, z = r_pos.z * factor, }
		local p_pos = vector.add(pos, r_pos)
		local dir = vector.direction(pos, p_pos)
		local particle = minetest.add_particle({
			pos = p_pos,
			velocity = vector.multiply(dir, -10),
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = factor / 10,
			size = 2,
			collisiondetection = false,
			texture = "black_hole_particle.png"
		})
	end
end

minetest.register_abm({
	nodenames = {"st_nodes:black_hole"},
	interval = 1,
	chance = 1,
	action = function(pos)
		-- Check if any players are within the black hole's gravitational field
		local objects = minetest.get_objects_inside_radius(pos, 40)
		for _, obj in ipairs(objects) do
			if obj:is_player() then
				calculate_gravity(obj, pos)
			end
		end

		generate_particles(pos)
	end,
})
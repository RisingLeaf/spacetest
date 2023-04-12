minetest.register_abm({
	nodenames = {"air"},
	interval = 10,
	chance = 10000000,
	action = function(pos)
		local num_particles = math.random(100, 200)
		local spread = 20
		for j=1,num_particles do
			local p_pos = {
				x = pos.x + math.random(-spread, spread) / 20,
				y = pos.y + math.random(-spread, spread) / 20,
				z = pos.z + math.random(-spread, spread) / 20,
			}
			local velocity = {
				x = math.random(-20, 20),
				y = math.random(-20, 20),
				z = math.random(-20, 20),
			}
			minetest.add_particle({
				pos = p_pos,
				texture = "cloud.png",
				size = 10,
				glow = 5,
				expirationtime = 5,
				velocity = velocity
			})
		end
	end
})
minetest.register_on_generated(function(minp, maxp, seed)
	-- Random chance to generate asteroid
	if math.random(1, 5) ~= 1 then
		return
	end

	-- Exclude the area around 0, 0, 0
	if (minp.x <= 10 and maxp.x >= -10) or
		(minp.y <= 10 and maxp.y >= -10) or
		(minp.z <= 10 and maxp.z >= -10) then
		return
	end

	-- Choose what to place
	local random_num = math.random(1, 2)

	if random_num == 1 then
		--- Generate the asteroid
		local vm = minetest.get_voxel_manip(minp, maxp, 1)
		local area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
		local data = vm:get_data()

		local mid = {x = (minp.x + maxp.x) / 2, y = (minp.y + maxp.y) / 2, z = (minp.z + maxp.z) / 2}

		local x_diff = (maxp.x - minp.x) / 2
		local y_diff = (maxp.y - minp.y) / 2
		local z_diff = (maxp.z - minp.z) / 2

		local radius = math.min(x_diff, y_diff, z_diff, 10)

		-- Modify the radius of the asteroid using Perlin noise
		local perlin = minetest.get_perlin(0, 3, 0.5, 10)
		for x = -x_diff, x_diff do
			for y = -y_diff, y_diff do
				for z = -z_diff, z_diff do
					local dist = math.sqrt(x*x + y*y + z*z)
					local n = perlin:get_2d({x = x + mid.x, y = z + mid.z})
					if dist < radius + n * 3 then
						data[area:index(x + mid.x, y + mid.y, z + mid.z)] = minetest.get_content_id("st_nodes:asteroid")
					end
				end
			end
		end

		-- Add holes to the asteroid using Perlin noise
		local perlin2 = minetest.get_perlin(0, 3, 0.5, 10)
		for x = -x_diff, x_diff do
			for y = -y_diff, y_diff do
				for z = -z_diff, z_diff do
					local dist = math.sqrt(x*x + y*y + z*z)
					local n = perlin2:get_3d({x = x + mid.x, y = y + mid.y, z = z + mid.z})
					if dist > radius - 3 and dist < radius - 1 and n > 0.3 then
						data[area:index(x + mid.x, y + mid.y, z + mid.z)] = minetest.get_content_id("air")
					end
				end
			end
		end

		-- Update the voxel manipulator and add the generated node to the world
		vm:set_data(data)
		vm:write_to_map()
	elseif random_num == 2 then
		-- Place a black hole
		local random_x = math.random(minp.x, maxp.x)
		local random_y = math.random(minp.y, maxp.y)
		local random_z = math.random(minp.z, maxp.z)
		local vm = minetest.get_voxel_manip(minp, maxp, 1)
		local area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
		local data = vm:get_data()
		data[area:index(random_x, random_y, random_z)] = minetest.get_content_id("st_nodes:black_hole")
		vm:set_data(data)
		vm:write_to_map()
	end

end)
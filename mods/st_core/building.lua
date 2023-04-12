-- Define the building menu item
minetest.register_tool("st_core:building_menu", {
	-- Item properties
	description = "Building Menu",
	inventory_image = "hammer.png",

	-- Item functions
	on_use = function(itemstack, player, pointed_thing)
		local meta = player:get_meta()
		local inv = player:get_inventory()

		-- Backup the current hotbar
		local hotbar_backup = {}
		for i=1,8 do
			hotbar_backup[i] = inv:get_stack("main", i):get_name()
		end

		-- Replace the hotbar with the building menu
		local item_names = {"st_nodes:base_metall", "st_nodes:energy_core", "st_nodes:research_facility", "st_nodes:turret"}
		for i=1,7 do
			inv:set_stack("main", i, ItemStack(item_names[i]))
		end

		-- Add a back tool to switch back to the projectile launcher and building menu hotbar
		inv:set_stack("main", 8, ItemStack("st_core:back_tool"))

		-- Store the backup hotbar and switch to the building menu hotbar
		meta:set_string("hotbar_backup", minetest.serialize(hotbar_backup))
		meta:set_string("current_hotbar", "building_menu")
	end,

	on_drop = function()
	end
})

-- Define the back tool
minetest.register_tool("st_core:back_tool", {
	-- Item properties
	description = "Back",
	inventory_image = "cross.png",

	-- Item functions
	on_use = function(itemstack, player, pointed_thing)
		local meta = player:get_meta()
		local inv = player:get_inventory()

		-- Restore the backup hotbar and switch back to it
		local hotbar_backup = minetest.deserialize(meta:get_string("hotbar_backup"))
		for i=1,8 do
			inv:set_stack("main", i, ItemStack(hotbar_backup[i]))
		end
		inv:remove_item("main", ItemStack("st_core:back_tool"))
		meta:set_string("current_hotbar", "projectile_launcher")
	end,

	on_drop = function()
	end
})

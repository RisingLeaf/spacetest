local function prepare()
	minetest.log("action", "[core] Preparing Level...")

	minetest.set_node({x=0, y=0, z=0}, {name="st_nodes:base_metall"})
end

minetest.register_on_joinplayer(function(player, last_login)
	minetest.set_player_privs(player:get_player_name(), {interact=true, shout=true, fly=true})
	player:set_pos(vector.new(0,0,0))
	player:set_physics_override({gravity = 0})
	player:hud_set_flags({hotbar = false, healthbar=false, crosshair=true, wielditem=false, breathbar=false})
	player:set_properties({
		mesh = "spaceship.obj",
		textures = {"spaceship.png"},
		visual = "mesh",
		visual_size = {x = 1, y = 1},
		collisionbox = {-0.5, 0.0, -0.5, 0.5, 1, 0.5},
		stepheight = 0.55,
		eye_height = 0.5,
	})
	player:set_sky({
		-- base_color = "#000000",
		type = "skybox",
		textures = {"space_edited.png", "space_edited.png", "space_edited.png", "space_edited.png", "space_edited.png", "space_edited.png"},
		clouds = false,
	})
	player:set_sun({
		visible = false,
		sunrise_visible = false,
	})
	player:set_moon({
		visible = false,
	})

	prepare()

	end
)
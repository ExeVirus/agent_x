------------------------------------------------------
-- !!! First time startup, overwrite map.sqlite !!!!!!
------------------------------------------------------
local world_path = core.get_worldpath()
local f = io.open(world_path .. "/env_meta.txt", "r")
if f == nil or not io.close(f) then
    core.cpdir(ax_core.mod_path.."/map", world_path)
end

core.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    ax_core.players[player_name] = {}
    ax_core.lang.players[player_name] = {}
    player:override_day_night_ratio(0)
    player:set_stars({visible=false})
    player:set_moon({visible=false})
    player:set_sun({visible=false})
    player:set_properties({
        textures = {"agent.png"},
        visual = "mesh",
        mesh = "agent.obj",
        visual_size = {x = 1, y = 1},
        collisionbox = {-0.24, 0.0, -0.26, 0.24, 0.25, 0.26},
        stepheight = 1,
        eye_height = 0,
        automatic_face_movement_dir = 0,
    })
end)
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
    ax_core.lang.players[player_name] = {
        playing_sounds = {}
    }
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
    ax_core.startup(player)
end)

ax_core.playing_music = nil
ax_core.play_music = function(player_name, sound, loop, start_time, fade_in, fade_out)
    ax_core.stop_music(fade_out)
    ax_core.playing_music = core.sound_play(sound,{
        loop = loop or false,
        to_player = player_name,
        fade = fade_in or 0.3,
        gain = ax_core.volume.music / 100,
        start_time = start_time or 0.0
    })
end

ax_core.stop_music = function(fade_out)
    if ax_core.playing_music then
        core.sound_fade(ax_core.playing_music, fade_out or 1, 0)
        ax_core.playing_music = nil
    end
end

ax_core.startup = function(player)
    local player_name = player:get_player_name()
    ax_core.play_music(player_name,"mainmenu", true)
    local script = {
        {"pos" ,0,0.5,4,0},
        {"look",0.5,0.5,4,5},
        -- {"line",2,0.5,4,50,5}, -- 10
        -- {"replay",0,"mainmenu",true},
        -- {"line",2,0.5,4,50,5}, -- 20
        -- {"replay",0,"mainmenu",true},
        -- {"line",2,0.5,4,50,5}, -- 30
        -- {"replay",0,"mainmenu",true},
        -- {"line",2,0.5,4,50,5}, -- 40
        -- {"replay",0,"mainmenu",true},
        -- {"line",2,0.5,4,48,5}, -- 48
        -- {"replay",0,"mainmenu",true},
    }
    if not ax_core.buildMode then
        ax_core.lang.script(player,"one_shot", script, function()
            core.show_formspec(player_name, "main_menu", ax_core.main_menu)
        end)
    end
end

ax_core.volume = core.deserialize(ax_core.mod_storage:get_string("volume")) or 
{
    music = 100,
    effects = 100,
    voice = 100,
}
ax_core.main_menu = table.concat({
    "formspec_version[10]",
    "size[7,6,false]",
    "position[0.5,0.5]",
    "anchor[0.5,0.75]",
    "no_prepend[]",
    "bgcolor[#0006]",
    "style_type[button;bgcolor=#11FF;font_size=50]",
    "button[2,1;3,1;start;Start]",
    "scrollbaroptions[min=0;max=100;smallstep=1;largestep=10;arrows=hide]",
    "hypertext[0,2.25;7,4;;<global halign=center font=normal size=20>Music Volume]",
    "scrollbar[0.5,2.75;6,0.3;;music;"..ax_core.volume.music.."]",
    "hypertext[0,3.25;7,4;;<global halign=center font=normal size=20>Effects Volume]",
    "scrollbar[0.5,3.75;6,0.3;;effects;"..ax_core.volume.effects.."]",
    "hypertext[0,4.25;7,4;;<global halign=center font=normal size=20>Voice Volume]",
    "scrollbar[0.5,4.75;6,0.3;;voice;"..ax_core.volume.voice.."]",
    "style_type[button;bgcolor=#511F;font_size=20]",
    "button[2.5,5.35;2,0.4;exit;Exit]",
})
local volume_callback_timers = {
    music = 0,
    effects = 0,
    voice = 0,
}
core.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "main_menu" then
        local volume = {}
        if fields.music then
            volume.music = tonumber(core.explode_scrollbar_event(fields.music).value)
        end
        if fields.effects then
            volume.effects = tonumber(core.explode_scrollbar_event(fields.effects).value)
        end
        if fields.voice then
            volume.voice = tonumber(core.explode_scrollbar_event(fields.voice).value)
        end
        for type,vol in pairs(volume) do
            if vol ~= ax_core.volume[type] then
                ax_core.volume[type] = volume[type]
                local timer_id = volume_callback_timers[type] + 1
                volume_callback_timers[type] = timer_id
                core.after(0.5, function()
                    if volume_callback_timers[type] == timer_id then
                        if type == "music" then
                            ax_core.play_music(player:get_player_name(),"mainmenu", true, 18.0)
                        elseif type == "effects" then
                            core.sound_play("lava",{gain=volume[type]/100})
                        else
                            core.sound_play("voice",{gain=volume[type]/100})
                        end
                        volume_callback_timers[type] = 0
                    end
                end)
            end
        end
        ax_core.mod_storage:set_string("volume", core.serialize(ax_core.volume))
        if fields.start then
            core.show_formspec(player:get_player_name(), "fadeout", ax_core.fadeout)
            core.after(0.9, function()
                ax_core.stop_music()
                ax_core.levels[2](player)
            end)
        end
        if fields.exit then
            core.request_shutdown("Thanks for playing!")
        end
    end
end)

ax_core.fadeout = table.concat({
    "formspec_version[10]",
    "size[800,800,true]",
    "position[-10,-10]",
    "anchor[0,0]",
    "no_prepend[]",
    "bgcolor[#0000]",
    "animated_image[0,0;800,800;;fadeout.png;255;5;0]",
})

ax_core.fadein = table.concat({
    "formspec_version[10]",
    "size[800,800,true]",
    "position[-10,-10]",
    "anchor[0,0]",
    "no_prepend[]",
    "bgcolor[#0000]",
    "animated_image[0,0;800,800;;fadein.png;255;5;0]",
})

ax_core.blackout = table.concat({
    "formspec_version[10]",
    "size[800,800,true]",
    "position[-10,-10]",
    "anchor[0,0]",
    "no_prepend[]",
    "bgcolor[#000F]",
})
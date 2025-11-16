--  █████  ██   ██      ██████  ██████  ██████  ███████
-- ██   ██  ██ ██      ██      ██    ██ ██   ██ ██
-- ███████   ███       ██      ██    ██ ██████  █████
-- ██   ██  ██ ██      ██      ██    ██ ██   ██ ██
-- ██   ██ ██   ██      ██████  ██████  ██   ██ ███████
--
-- MIT License, See License.txt
-- Ascii art generated with https://patorjk.com/software/taag/

-----------------------------------------
-- Everything can be modified, public API
-----------------------------------------
ax_core = {} -- global table for other dependent mod access
ax_core.buildMode = false -- Control ax_core globally: `true` for making/building levels and testing the game, `false` for releases
ax_core.mod_path = core.get_modpath(core.get_current_modname())
ax_core.mod_storage = core.get_mod_storage()

------------------------------------------------------
-- This really should exist in core, builtin luanti
------------------------------------------------------
table.merge = function(dest, src)
    local ret_val = table.copy(dest)
    for k, v in pairs(src) do ret_val[k] = v end
    return ret_val
end

dofile(ax_core.mod_path .. "/chat_commands.lua")
dofile(ax_core.mod_path .. "/lang.lua")
dofile(ax_core.mod_path .. "/nodes.lua")
dofile(ax_core.mod_path .. "/physics.lua")
dofile(ax_core.mod_path .. "/replay.lua")
dofile(ax_core.mod_path .. "/startup.lua")

-- -------------------
-- -- Main Menu and startup
-- -------------------
-- minetest.register_on_joinplayer(function(player)
--     -- Show off little Lady!
--     player:set_properties({
--         mesh = "lady_assets_littlelady.obj",
--         textures = {"lady_assets_ladybug.png"},
--         visual = "mesh",
--         visual_size = {x = 1, y = 1},
--         collisionbox = {-0.24, 0.0, -0.26, 0.24, 1, 0.26},
--         stepheight = 0.55,
--         eye_height = 1,
--     })
--     -- Turn off builtin crap
--     player:hud_set_flags(
--         {
--             hotbar = false,
--             healthbar = false,
--             crosshair = false,
--             wielditem = false,
--             breathbar = false,
--             minimap = false,
--             minimap_radar = false,
--         }
--     )
--     --set to always sunny in CalifornIA
--     player:override_day_night_ratio(1)
--     player:set_stars({visible=false})
--     player:set_moon({visible=false})
--     player:set_sun({visible=false})

-- --  1. Turn off player gravity and stop them from falling
--     player:set_physics_override({
--         speed = 0.0,
--         jump = 0.0,
--         gravity = 0.0,
--         sneak = false,
--     })
-- --  2. Change the player's "I" in-game menu to quit to main menu, reset, quit, and credits
--     player:set_inventory_formspec(table.concat(
--         {
--             "formspec_version[3]",
--             "size[8,9]",
--             "position[0.5,0.5]",
--             "anchor[0.5,0.5]",
--             "no_prepend[]",
--             "bgcolor[",background_primary_c,";both;#AAAAAA40]",
--             "style_type[button;border=false;bgimg=back.png^[multiply:",primary_c,";bgimg_middle=10,10;textcolor=",on_primary_c,"]",
--             "style_type[button:hovered;bgimg=back.png^[multiply:",hover_primary_c,";bgcolor=#FFF]",
--             "button_exit[0.6,0.25;6.8,1;menu;Quit to Menu]",
--             "button_exit[0.6,1.5;6.8,1;reset;Reset to start]",
--             "button_exit[0.6,2.75;6.8,1;view;View Starting Message]",
--             "hypertext[2,4;4,4.75;;<global halign=center color=",primary_c," size=32 font=Regular>Credits<global halign=center color=",on_secondary_c," size=16 font=Regular>\n",
--             "Original Game by ExeVirus\n",
--             "Source code is MIT License, 2021\n",
--             "Media/Music is:\nSee LICENSE Files\n",
--             "Music coming to Spotify and other streaming services!\n]",
--         }
--     ))
-- -- 3. Display the main Menu
--     minetest.show_formspec(player:get_player_name(),"menu",main_menu())
-- end)

-- -------------------
-- --On receive
-- -------------------
-- minetest.register_on_player_receive_fields(function(player, formname, fields)
--     local scroll_in = nil
--     if formname == "menu" then
--         if fields.scroll then
--             scroll_in = tonumber(minetest.explode_scrollbar_event(fields.scroll).value)
--         end
--             --Loop through all fields for level selected
--         for fieldtext,_ in pairs(fields) do
--             if string.sub(fieldtext,1,5) == "level" then
--                 loaded_level = tonumber(string.sub(fieldtext,6,-1))
--                 if levels[loaded_level] ~= nil and loaded_level <= current_level then
--                     load_level(player)
--                     minetest.close_formspec(player:get_player_name(),"menu")
--                 else
--                     loaded_level = nil
--                 end
--             end
--         end
--         if fields.quit then
--             minetest.after(0.10, function() minetest.show_formspec(player:get_player_name(), "menu", main_menu(scroll_in)) end)
--             return
--         elseif fields.exit then
--             minetest.request_shutdown("Thanks for playing!")
--             return
--         else
--             --minetest.show_formspec(player:get_player_name(), "game:main", main_menu(width_in, height_in, scroll_in))
--         end
--     elseif formname == "" then --pause menu
--         if fields.menu then
--             unload_level(player, false)
--         elseif fields.reset then
--             reset_player(player)
--         elseif fields.view then
--             minetest.after(0.15,function(player)
--                 minetest.show_formspec(player:get_player_name(),"level",levels[loaded_level].formspec)
--             end,player)
--         end
--     elseif formname == "win" then
--         minetest.after(0.10, function() minetest.show_formspec(player:get_player_name(), "menu", main_menu()) end)
--     elseif formname == "level" then
--         if loaded_level ~= nil then
--             formspec_read = true
--             if level_loaded then
--                 globalsteps_enabled = true
--             end
--         end
--     end
-- end)


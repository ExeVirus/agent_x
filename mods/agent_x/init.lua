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
ax_core.buildMode = true -- Control ax_core globally: `true` for making/building levels and testing the game, `false` for releases
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


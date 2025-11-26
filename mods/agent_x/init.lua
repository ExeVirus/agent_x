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
dofile(ax_core.mod_path .. "/effects.lua")
dofile(ax_core.mod_path .. "/lang.lua")
dofile(ax_core.mod_path .. "/levels.lua")
dofile(ax_core.mod_path .. "/nodes.lua")
dofile(ax_core.mod_path .. "/physics.lua")
dofile(ax_core.mod_path .. "/replay.lua")
dofile(ax_core.mod_path .. "/startup.lua")

-- //mix ax_core:floor_1 2 ax_core:floor_2 2 ax_core:floor_3 1
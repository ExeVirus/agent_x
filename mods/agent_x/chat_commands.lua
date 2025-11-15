
------
-- Most chat commands only exist in build mode
------
core.register_chatcommand("ax",
{
    params = "",
    description = "Toggle ax mode",
    privs = {},
    func = function(name, params)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end
        local stack = ItemStack("ax_core:gun")
        player:get_inventory():set_list("main", {stack})
        player:set_wielded_item(stack)
        ax_core.enable(name)
        return true, "AX mode toggled."
    end
})

-- if ax_core.buildMode then

core.register_chatcommand("cage_neons", 
{
    params = "x,y,z,x2,y2,z2",
    description = "Camera Control API, groups of {} are executed in order until completion",
    privs = {},
    func = function(name, params)
        local value_pattern = "^%s*[+-]?%d*%.?%d+%s*$"
        local args = {}
        local parts = {}
        for part in params:gmatch("([^,]+)") do
            table.insert(parts, part)
        end
        if #parts == 6 then
            local all_values_valid = true
            for i = 1, #parts do
                local numeric_val_str = parts[i]:match(value_pattern)
                if numeric_val_str then
                    table.insert(args, tonumber(numeric_val_str))
                else
                    all_values_valid = false
                    break
                end
            end
            if all_values_valid then
                ax_core.cage_neons(unpack(parts))
            else
                return nil, "Invalid numeric value in params: " .. params
            end
        else
            return nil, "Needs 6 arguments: " .. params
        end
    end
})

core.register_chatcommand("start",
{
    params = "<replay name>",
    description = "Start AX replay",
    privs = {},
    func = function(name, params)
        return ax_core.start_replay(name, params)
    end
})

core.register_chatcommand("stop",
{
    params = "",
    description = "Stop Current AX replay",
    privs = {},
    func = function(name, params)
        return ax_core.stop_replay(name)
    end
})

core.register_chatcommand("play",
{
    params = "<replay name>",
    description = "Playback AX replay",
    privs = {},
    func = function(name, params)
        return ax_core.play_replay(params)
    end
})

core.register_chatcommand("phys",
{
    params = "str,mass,air,gravity,friction_time",
    description = "AX phys",
    privs = {},
    func = function(name, params)
        -- Split the parameter string by the comma
        local parts = string.split(params, ",")
        if #parts ~= 5 then
            return false, "Invalid format. Usage: /phys str,mass,air,gravity,friction_time"
        end
        local str  = tonumber(string.trim(parts[1]))
        local mass = tonumber(string.trim(parts[2]))
        local air  = tonumber(string.trim(parts[3]))
        local grav = tonumber(string.trim(parts[4]))
        local fric = tonumber(string.trim(parts[5]))
        if not str or not mass or not air or not grav or not fric then
            return false, "Invalid numbers. Usage: /phys str,mass,air,gravity,friction_time"
        end
        if not ax_core.players[name] then
            ax_core.players[name] = {}
        end
        ax_core.physics.strength = str
        ax_core.physics.mass = mass
        ax_core.physics.air_resistance = air
        ax_core.physics.gravity = grav
        ax_core.physics.friction = fric
        return true
    end
})

core.register_chatcommand("camera", 
{
    params = "{pos|look|fov,seconds,val,val,val}{}{}{}",
    description = "Camera Control API, groups of {} are executed in order until completion",
    privs = {},
    func = function(name, params)
        ax_camera.camera(core.get_player_by_name(name), params, "one_shot")
    end
})

core.register_chatcommand("camera_loop", 
{
    params = "{pos|look|fov,seconds,val,val,val}{}{}{}",
    description = "Camera Control API, groups of {} are executed in order until completion",
    privs = {},
    func = function(name, params)
        ax_camera.camera(core.get_player_by_name(name), params, "loop")
    end
})

-- end
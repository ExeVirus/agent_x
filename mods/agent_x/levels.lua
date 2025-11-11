--  █████  ██   ██      ██████  █████  ███    ███ ███████ ██████   █████
-- ██   ██  ██ ██      ██      ██   ██ ████  ████ ██      ██   ██ ██   ██
-- ███████   ███       ██      ███████ ██ ████ ██ █████   ██████  ███████
-- ██   ██  ██ ██      ██      ██   ██ ██  ██  ██ ██      ██   ██ ██   ██
-- ██   ██ ██   ██      ██████ ██   ██ ██      ██ ███████ ██   ██ ██   ██
-- 
-- MIT License, See License.txt

ax_camera = {}
local function get_eye_offset(player)
    local camera_mode = player:get_camera().mode
    if camera_mode == "any" then
        camera_mode = "first"
    end
    local eye_pos = vector.zero()
    eye_pos.y = eye_pos.y + player:get_properties().eye_height
    local first, third, third_front = player:get_eye_offset()
    local lookup = {
        first = first,
        third = third,
        third_front = third_front
    }
    eye_pos = vector.add(eye_pos, vector.divide(lookup[camera_mode], 10)) -- eye offsets are in block space (10x), transform them back to metric
    return eye_pos
end
ax_camera.command_num_args = {
    pos = 4,
    look = 4,
    fov = 2,
    line = 5,
    line_look = 8,
    line_look_line = 9,
    circle = 5,
    circle_look = 8,
    circle_look_line = 9,
}
ax_camera.commands = {
    pos = function(player,orig_pos,dtime,x,y,z)
        player:set_pos(vector.new(x,y,z))
    end,
    look = function(player,orig_pos,dtime,x,y,z)
        local look_location = vector.new(x,y,z)
        local look_dir = vector.direction(vector.add(orig_pos, get_eye_offset(player)), look_location)
        local pitch = -math.asin(look_dir.y)
        local yaw = math.atan2(-look_dir.x, look_dir.z)
        player:set_look_horizontal(yaw)
        player:set_look_vertical(pitch)
        ax_camera.players[player:get_player_name()].last_look = look_location
    end,
    fov = function(player,orig_pos,dtime,fov)
        player:set_fov(fov)
    end,
    line = function(player,orig_pos,dtime,x,y,z,speed)
        local distance_this_tick = speed*dtime
        local target_pos = vector.new(x,y,z)
        if vector.distance(orig_pos, target_pos) > distance_this_tick then
            local offset = vector.multiply(vector.direction(orig_pos,target_pos),distance_this_tick)
            local new_pos = vector.add(orig_pos,offset)
            player:set_pos(new_pos)
            return new_pos
        else 
            player:set_pos(target_pos)
            return target_pos
        end
    end,
    line_look = function(player,orig_pos,dtime,x,y,z,speed,lookx,looky,lookz)
        local new_pos = ax_camera.commands.line(player,orig_pos,dtime,x,y,z,speed)
        ax_camera.commands.look(player,new_pos,dtime,lookx,looky,lookz)
    end,
    line_look_line = function(player,orig_pos,dtime,x,y,z,speed,lookx,looky,lookz,look_speed)
        local new_pos = ax_camera.commands.line(player,orig_pos,dtime,x,y,z,speed)
        local last_look_location = ax_camera.players[player:get_player_name()].last_look
        local target_look_location = vector.new(lookx,looky,lookz)
        local distance_this_tick = look_speed*dtime
        if vector.distance(last_look_location, target_look_location) > distance_this_tick then
            local new_look_offset = vector.multiply(vector.direction(last_look_location,target_look_location),distance_this_tick)
            local new_look = vector.add(last_look_location,new_look_offset)
            ax_camera.commands.look(player,new_pos,dtime,new_look.x,new_look.y,new_look.z)
        else
            ax_camera.commands.look(player,new_pos,dtime,target_look_location.x,target_look_location.y,target_look_location.z)
        end
    end,
    circle = function(player,orig_pos,dtime,center_x,center_z,arc_speed,y_speed)
        local delta_x = orig_pos.x - center_x
        local delta_z = orig_pos.z - center_z
        local radius = math.sqrt(delta_x * delta_x + delta_z * delta_z)
        if radius < 0.0001 then return end
        local angle_to_rotate = arc_speed * dtime / radius
        local cos_a = math.cos(angle_to_rotate)
        local sin_a = math.sin(angle_to_rotate)
        local new_delta_x = delta_x * cos_a - delta_z * sin_a
        local new_delta_z = delta_x * sin_a + delta_z * cos_a
        local new_x = center_x + new_delta_x
        local new_z = center_z + new_delta_z
        local new_pos = vector.new(new_x,orig_pos.y + y_speed*dtime,new_z)
        player:set_pos(new_pos)
        return new_pos
    end,
    circle_look = function(player,orig_pos,dtime,center_x,center_z,arc_speed,y_speed,lookx,looky,lookz)
        local new_pos = ax_camera.commands.circle(player,orig_pos,dtime,center_x,center_z,arc_speed,y_speed)
        ax_camera.commands.look(player,new_pos,dtime,lookx,looky,lookz)
    end,
    circle_look_line = function(player,orig_pos,dtime,center_x,center_z,arc_speed,y_speed,lookx,looky,lookz,look_speed)
        local new_pos = ax_camera.commands.circle(player,orig_pos,dtime,center_x,center_z,arc_speed,y_speed)
        local last_look_location = ax_camera.players[player:get_player_name()].last_look
        local target_look_location = vector.new(lookx,looky,lookz)
        local distance_this_tick = look_speed*dtime
        if vector.distance(last_look_location, target_look_location) > distance_this_tick then
            local new_look_offset = vector.multiply(vector.direction(last_look_location,target_look_location),distance_this_tick)
            local new_look = vector.add(last_look_location,new_look_offset)
            ax_camera.commands.look(player,new_pos,dtime,new_look.x,new_look.y,new_look.z)
        else
            ax_camera.commands.look(player,new_pos,dtime,target_look_location.x,target_look_location.y,target_look_location.z)
        end
    end,
}
ax_camera.players = {}

function parse_params(params)
    local commands = {}
    local command_pattern = "^%s*[%w_]+%s*$"
    local value_pattern = "^%s*[+-]?%d*%.?%d+%s*$"

    for command_group in params:gmatch("{([^}]+)}") do
        local parts = {}
        for part in command_group:gmatch("([^,]+)") do
            table.insert(parts, part)
        end
        -- A valid group must have at least a command and a time
        if #parts >= 2 then 
            local command_name = parts[1]:match(command_pattern)
            if command_name and ax_camera.commands[command_name] then
                local command_info = {
                    command = command_name,
                    args = {}
                }
                local all_values_valid = true
                for i = 2, #parts do
                    local numeric_val_str = parts[i]:match(value_pattern)
                    if numeric_val_str then
                        table.insert(command_info.args, tonumber(numeric_val_str))
                    else
                        all_values_valid = false
                        break
                    end
                end

                if all_values_valid then
                    local num_args = ax_camera.command_num_args[command_info.command]
                    if #command_info.args == num_args then
                        table.insert(commands, command_info)
                    else
                        return nil, "Invalid number of args for command "..command_info.command
                                     ..", expected "..num_args.." , command group: " .. command_group
                    end
                else
                    return nil, "Invalid numeric value in group: " .. command_group
                end
            else
                return nil, "Invalid command name in group: " .. command_group
            end
        else
            return nil, "Group has insufficient arguments: " .. command_group
        end
    end

    return commands
end

ax_camera.camera = function(player, params, mode)
    if player ~= nil and type(params) == "string" then
        local commands, error = parse_params(params)
        local player_name = player:get_player_name()
        if error ~= nil then
            core.chat_send_player(player_name, error)
            return
        end
        if commands ~= nil and #commands > 0 then
            ax_camera.players[player_name] = {
                commands = commands,
                mode = mode,
                index = 1,
                time_remaining = commands[1].args[1],
                last_look = vector.zero()
            }
        end
    end
end

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

core.register_globalstep(function(dtime)
    for player_name, camera in pairs(ax_camera.players) do
        if camera.commands ~= nil then
            local remaining_dtime = dtime
            local player = core.get_player_by_name(player_name)
            while remaining_dtime > 0 do
                local current_command = camera.commands[camera.index]
                local command_name = current_command.command
                local num_args = ax_camera.command_num_args[command_name]
                ax_camera.commands[command_name](player, player:get_pos(), remaining_dtime, unpack(current_command.args,2,num_args))
                if remaining_dtime < camera.time_remaining then
                    camera.time_remaining = camera.time_remaining - remaining_dtime
                    remaining_dtime = 0
                else
                    remaining_dtime = remaining_dtime - camera.time_remaining
                    camera.index = camera.index + 1
                    if camera.index > #camera.commands then
                        if camera.mode == "one_shot" then
                            camera.commands = nil
                            break -- we're done here
                        else
                            camera.index = 1
                        end
                    end
                    camera.time_remaining = camera.commands[camera.index].args[1]
                end
            end
        end
    end
end)

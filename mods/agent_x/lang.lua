--    ░███    ░██    ░██    ░██            ░███    ░███    ░██   ░██████
--   ░██░██    ░██  ░██     ░██           ░██░██   ░████   ░██  ░██   ░██
--  ░██  ░██    ░██░██      ░██          ░██  ░██  ░██░██  ░██ ░██
-- ░█████████    ░███       ░██         ░█████████ ░██ ░██ ░██ ░██  █████
-- ░██    ░██   ░██░██      ░██         ░██    ░██ ░██  ░██░██ ░██     ██
-- ░██    ░██  ░██  ░██     ░██         ░██    ░██ ░██   ░████  ░██  ░███
-- ░██    ░██ ░██    ░██    ░██████████ ░██    ░██ ░██    ░███   ░█████░█
--
-- A very not clean implementation of a decent scripting language for Agent X
--
-- All functions take a time parameter, which is time ni seconds to run this command for
-- For instant functions, let pos(), this is the time to sit around doing nothing before
-- the next command
--
-- # Functions:
--
-- {pos,time,x,y,z}
-- {fov,time,fov}
-- {look,time,x,y,z}
-- {line,time,x,y,z,speed}
-- {line_look,time,x,y,z,speed,lookx,looky,lookz}
-- {line_look_line,time,x,y,z,speed,lookx,looky,lookz,look_speed}
-- {circle,time,center_x,center_z,arc_speed,y_speed}
-- {circle_look,time,center_x,center_z,arc_speed,y_speedlookx,looky,lookz}
-- {circle_look_line,time,center_x,center_z,arc_speed,y_speedlookx,looky,lookz,look_speed}
-- {sound,time,sound,gain,loop,play_time}
-- {replay,time,replay_name,loop}
-- {attach,time}
-- {detach,time}
-- {title,time,text,color(#RRGGBB),fadein,steady,fadeout}
-- {text,time,text,word_time,extra_time}
-- {wait,time}
-- {detect,time,x1,y1,z1,x2,y2,z2}

-- Example Script:
-- /script {sound`0`"welcome"``1.0`0`5} {text`0`"Welcome, Agent X, to your first mission"`0.25`1.0} {pos`0`-33`7.6`13.9} {circle_look`2.75`-18.5`4.3`-10`-0.4`-18.4`4.3`13.9}

ax_core.lang = {}
function ax_core.get_eye_offset(player)
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

ax_core.lang.command_num_args = {
    pos = 4,
    look = 4,
    fov = 2,
    line = 5,
    line_look = 8,
    line_look_line = 9,
    circle = 5,
    circle_look = 8,
    circle_look_line = 9,
    sound = 5,
    replay = 3,
    attach = 1,
    detach = 1,
    title = 6,
    text = 4,
    wait = 1,
    detect = 7,
}

ax_core.lang.commands = {
    pos = function(player,orig_pos,dtime,x,y,z)
        player:set_pos(vector.new(x,y,z))
    end,
    look = function(player,orig_pos,dtime,x,y,z)
        local look_location = vector.new(x,y,z)
        local look_dir = vector.direction(vector.add(orig_pos, ax_core.get_eye_offset(player)), look_location)
        local pitch = -math.asin(look_dir.y)
        local yaw = math.atan2(-look_dir.x, look_dir.z)
        player:set_look_horizontal(yaw)
        player:set_look_vertical(pitch)
        ax_core.lang.players[player:get_player_name()].last_look = look_location
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
        local new_pos = ax_core.lang.commands.line(player,orig_pos,dtime,x,y,z,speed)
        ax_core.lang.commands.look(player,new_pos,dtime,lookx,looky,lookz)
    end,
    line_look_line = function(player,orig_pos,dtime,x,y,z,speed,lookx,looky,lookz,look_speed)
        local new_pos = ax_core.lang.commands.line(player,orig_pos,dtime,x,y,z,speed)
        local last_look_location = ax_core.lang.players[player:get_player_name()].last_look
        local target_look_location = vector.new(lookx,looky,lookz)
        local distance_this_tick = look_speed*dtime
        if vector.distance(last_look_location, target_look_location) > distance_this_tick then
            local new_look_offset = vector.multiply(vector.direction(last_look_location,target_look_location),distance_this_tick)
            local new_look = vector.add(last_look_location,new_look_offset)
            ax_core.lang.commands.look(player,new_pos,dtime,new_look.x,new_look.y,new_look.z)
        else
            ax_core.lang.commands.look(player,new_pos,dtime,target_look_location.x,target_look_location.y,target_look_location.z)
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
        local new_pos = ax_core.lang.commands.circle(player,orig_pos,dtime,center_x,center_z,arc_speed,y_speed)
        ax_core.lang.commands.look(player,new_pos,dtime,lookx,looky,lookz)
    end,
    circle_look_line = function(player,orig_pos,dtime,center_x,center_z,arc_speed,y_speed,lookx,looky,lookz,look_speed)
        local new_pos = ax_core.lang.commands.circle(player,orig_pos,dtime,center_x,center_z,arc_speed,y_speed)
        local last_look_location = ax_core.lang.players[player:get_player_name()].last_look
        local target_look_location = vector.new(lookx,looky,lookz)
        local distance_this_tick = look_speed*dtime
        if vector.distance(last_look_location, target_look_location) > distance_this_tick then
            local new_look_offset = vector.multiply(vector.direction(last_look_location,target_look_location),distance_this_tick)
            local new_look = vector.add(last_look_location,new_look_offset)
            ax_core.lang.commands.look(player,new_pos,dtime,new_look.x,new_look.y,new_look.z)
        else
            ax_core.lang.commands.look(player,new_pos,dtime,target_look_location.x,target_look_location.y,target_look_location.z)
        end
    end,
    sound = function(player,orig_pos,dtime,sound,gain,loop,play_time)
        table.insert(ax_core.playing_sounds,{
            play_time = play_time,
            played_for_time = 0,
            handle = core.sound_play(sound,{
                gain = gain,
                loop = loop ~= 0,
                to_player = player:get_player_name(),
            })
        })
    end,
    replay = function(player,orig_pos,dtime,replay_name,loop)
        ax_core.play_replay(replay_name, loop ~= 0)
    end,
    attach = function(player,orig_pos,dtime)
        ax_core.enable(player:get_player_name())
    end,
    detach = function(player,orig_pos,dtime)
        ax_core.disable(player:get_player_name())
    end,
    title = function(player,orig_pos,dtime,text,color,fadein,steady,fadeout)
        local player_name = player:get_player_name()
        ax_core.lang.players[player_name].title = {
            text = text,
            color = color,
            fadein = fadein,
            steady = fadein + steady,
            fadeout = fadein + steady + fadeout,
            current_time = 0
        }
    end,
    text = function(player,orig_pos,dtime,text,word_time,extra_time)
        local player_name = player:get_player_name()
        local text_array = {}
        for word in string.gmatch(text, "%S+") do
            table.insert(text_array, word)
        end
        if (#text_array > 0) then
            ax_core.lang.players[player_name].text = {
                text_array = text_array,
                word_time = word_time,
                total_time = word_time * #text_array + extra_time,
                current_time = 0
            }
        end
    end,
    wait = function(player,orig_pos,dtime)
    end,
    detect = function(player,orig_pos,dtime,x1,y1,z1,x2,y2,z2)
        local min = vector.new(
            math.min(x1, x2),
            math.min(y1, y2),
            math.min(z1, z2)
        )
        local max = vector.new(
            math.max(x1, x2),
            math.max(y1, y2),
            math.max(z1, z2)
        )
        if vector.in_area(player:get_pos(), min, max) then
            local script = ax_core.lang.players[player:get_player_name()].script
            script.index = script.index + 1
            if script.index > #script.commands then
                if script.mode == "one_shot" then
                    script.commands = nil
                else
                    script.index = 1
                end
            end
            script.time_remaining = script.commands[script.index].args[1]
        end
    end
}
ax_core.lang.players = {}
ax_core.playing_sounds = {}

function ax_core.parse_params(params)
    local commands = {}
    local command_pattern = "^%s*[%w_]+%s*$"
    local value_pattern = "^%s*[+-]?%d*%.?%d+%s*$"
    local string_pattern = "^%s*\"(.-)\"%s*$"

    for command_group in params:gmatch("{([^}]+)}") do
        local parts = {}
        for part in command_group:gmatch("([^`]+)") do
            table.insert(parts, part)
        end
        -- A valid group must have at least a command and a time
        if #parts >= 2 then 
            local command_name = parts[1]:match(command_pattern)
            if command_name and ax_core.lang.commands[command_name] then
                local command_info = {
                    command = command_name,
                    args = {}
                }
                local all_values_valid = true
                local invalid_value = ""
                for i = 2, #parts do
                    local numeric_val_str = parts[i]:match(value_pattern)
                    local string_val_str = parts[i]:match(string_pattern)
                    if numeric_val_str then
                        table.insert(command_info.args, tonumber(numeric_val_str))
                    elseif string_val_str then
                        table.insert(command_info.args, tostring(string_val_str))
                    else
                        all_values_valid = false
                        invalid_value = parts[i]
                        break
                    end
                end

                if all_values_valid then
                    local num_args = ax_core.lang.command_num_args[command_info.command]
                    if #command_info.args == num_args then
                        table.insert(commands, command_info)
                    else
                        return nil, "Invalid number of args for command "..command_info.command
                                     ..", got "..#command_info.args..", expected "..num_args.." , command group: " .. command_group
                    end
                else
                    return nil, "Invalid value: `"..invalid_value.."` in group: " .. command_group
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

function ax_core.lang.script(player, params, mode)
    if player ~= nil and type(params) == "string" then
        local commands, error = ax_core.parse_params(params)
        local player_name = player:get_player_name()
        if error ~= nil then
            core.chat_send_player(player_name, error)
            return
        end
        if commands ~= nil and #commands > 0 then
            ax_core.lang.players[player_name].script = {
                commands = commands,
                mode = mode,
                index = 1,
                time_remaining = commands[1].args[1],
                last_look = vector.zero()
            }
        end
    end
end
ax_core.make_title_formspec = function(title,color,zero_to_one_shown)
    local alpha_channel = string.format("%02X", math.floor(zero_to_one_shown * 255))
    return table.concat({
        "formspec_version[10]",
        "size[18,4,false]",
        "position[0.5,0]",
        "anchor[0.5,0]",
        "no_prepend[]",
        "bgcolor[#0000]",
        "hypertext[0,0;18,4;;<global color="..color..alpha_channel.." halign=center valign=top font=normal size=150>"..title.."]",
    })
end
ax_core.make_text_formspec = function(text)
    return table.concat({
        "formspec_version[10]",
        "size[18,2,false]",
        "position[0.5,0]",
        "anchor[0.5,0]",
        "no_prepend[]",
        "bgcolor[#000B]",
        "hypertext[0.1,0;17.8,2;;<global color=#00E32D halign=left valign=top font=normal size=30>",
        text,"]",
    })
end
core.register_globalstep(function(dtime)
    for player_name, player_data in pairs(ax_core.lang.players) do
        if player_data.script ~= nil and player_data.script.commands ~= nil then
            local script = player_data.script
            local remaining_dtime = dtime
            local player = core.get_player_by_name(player_name)
            while remaining_dtime > 0 do
                local current_command = script.commands[script.index]
                local command_name = current_command.command
                local num_args = ax_core.lang.command_num_args[command_name]
                local before_command_index = script.index
                ax_core.lang.commands[command_name](player, player:get_pos(), remaining_dtime, unpack(current_command.args,2,num_args))
                if script.index == before_command_index then
                    if remaining_dtime < script.time_remaining then
                        script.time_remaining = script.time_remaining - remaining_dtime
                        remaining_dtime = 0
                    else
                        remaining_dtime = remaining_dtime - script.time_remaining
                        script.index = script.index + 1
                        if script.index > #script.commands then
                            if script.mode == "one_shot" then
                                script.commands = nil
                                break
                            else
                                script.index = 1
                            end
                        end
                        script.time_remaining = script.commands[script.index].args[1]
                    end
                else
                    remaining_dtime = 0
                end
            end
        end
        if player_data.title then
            local title = player_data.title
            title.current_time = title.current_time + dtime
            local alpha_percent = 0
            if title.current_time <= title.fadein then
                alpha_percent = title.current_time / title.fadein
            elseif title.current_time <= title.steady then
                alpha_percent = 1
            elseif title.current_time <= title.fadeout then
                alpha_percent =  1 - ((title.current_time - title.steady) / (title.fadeout - title.steady))
            else
                player_data.title = nil
                core.close_formspec(player_name, "title")
                goto continue_loop
            end
            core.show_formspec(player_name, "title", ax_core.make_title_formspec(
                title.text,
                title.color,
                alpha_percent
            ))
        end
        if player_data.text then
            local text = player_data.text
            text.current_time = text.current_time + dtime
            if text.current_time > text.total_time then
                player_data.text = nil
                core.close_formspec(player_name, "text")
                goto continue_loop
            end
            core.show_formspec(player_name, "text", ax_core.make_text_formspec(
                table.concat(text.text_array," ", 1, math.min(#text.text_array,math.floor(text.current_time / text.word_time)))
            ))
        end
        ::continue_loop::
    end
    for _, playing_sound in pairs(ax_core.playing_sounds) do
        if playing_sound.play_time > 0 then
            playing_sound.played_for_time = playing_sound.played_for_time + dtime
            if playing_sound.played_for_time > playing_sound.play_time then
                core.sound_stop(playing_sound.handle)
            end
        end
    end
end)

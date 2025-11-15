ax_core.replays = {}

ax_core.agent_properties.initial_properties.collide_with_objects = false
core.register_entity("ax_core:agent_replay", ax_core.agent_properties)

ax_core.start_replay = function(name, params)
    if string.match(params, "^%w+$") == nil then
        return false, "Improper Arguments: 1 arg, alphanumerics only"
    end
    ax_core.players[name].replay = {
        name = params,
        time = core.get_us_time(),
        entries = {
            {
                time = core.get_us_time(),
                target = ax_core.players[name].target,
                strength = ax_core.players[name].strength
            }
        },
        starting_pos = core.get_player_by_name(name):get_pos()
    }
    return true, "replay Started."
end

ax_core.stop_replay = function(name)
    if ax_core.players[name].replay then
        local replay = ax_core.players[name].replay
        table.insert(replay.entries, {
            time = core.get_us_time(),
            target = nil,
            strength = nil,
        })
        local replay_name = replay.name
        for i=1, #replay.entries, 1 do
            replay.entries[i].time = (replay.entries[i].time - replay.time) / 1000000 -- microseconds -> seconds
        end
        ax_core.mod_storage:set_string(replay_name, core.serialize({
            entries = table.copy(replay.entries),
            starting_pos = vector.copy(replay.starting_pos)
        }))
        ax_core.players[name].replay = nil
        return true, "replay '" .. replay_name .. "' saved with " .. #replay.entries .. " entries."
    else
        return false, "No current replay to stop"
    end
end

ax_core.play_replay = function(params)
    if string.match(params, "^%w+$") == nil then
        return false, "Improper Arguments: 1 arg, alphanumerics only"
    end
    local replay = core.deserialize(ax_core.mod_storage:get_string(params))
    if replay == nil then
        return false, "No replay '" .. params .. "' Found."
    end
    local entity = core.add_entity(replay.starting_pos, "ax_core:agent_replay")
    if entity then
        entity:get_luaentity().replay = {
            index = 1,
            time = 0,
            entries = table.copy(replay.entries),
        }
        return true
    else
        return false, "Couldn't Create Playback Entity!!"
    end
end
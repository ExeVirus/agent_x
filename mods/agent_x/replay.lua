ax_core.players = {}
ax_core.physics = {
    strength = 100,
    mass = 5,
    air_resistance = -8,
    gravity = -5,
    friction = 0.2,
}
ax_core.recordings = {}

core.register_on_joinplayer(function(player)
  local player_name = player:get_player_name()
  ax_core.players[player_name] = {}
end)

core.register_entity("ax_core:agent", {
    initial_properties = {
        physical = true,
        collide_with_objects = false,
        pointable = false,
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 2, 0.5},
        visual = "sprite",
        textures = {"default_cobble.png"}
    },

    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 1})
    end,

    static_save = false,

    on_step = function(self, dtime, moveresult)
        local player_data = {}
        if self.player_name then
            player_data = ax_core.players[self.player_name]
        elseif self.recording then
            local record = self.recording
            record.time = record.time + dtime
            while record.time > record.entries[record.index].time do
                record.index = record.index + 1
                if record.index > #record.entries then
                    self.object:remove()
                    return
                end
            end
            player_data = {
                target = record.entries[record.index].target
            }
        else
            self.object:remove()
            return
        end
        local physics = ax_core.physics

        -- If we don't have a player or target, do nothing.
        local velocity = self.object:get_velocity()
        local distance = 100
        if not player_data or not player_data.target then
            -- Apply basic gravity if there's no attractor active
            velocity.y = velocity.y + (physics.gravity * dtime)
            self.object:set_velocity(velocity)
        else
            -- Physics Model
            local current_pos = self.object:get_pos()
            local target_pos = player_data.target
            local vector_to_target = vector.subtract(target_pos, current_pos)
            distance = vector.length(vector_to_target)
            
            -- To prevent division by zero if we are exactly at the target
            if distance < 0 then
                self.object:set_velocity(velocity)
                return
            end
            local direction = vector.normalize(vector_to_target)
            local gravity_force = vector.new(0, physics.mass * physics.gravity, 0)
            local pull_force = vector.multiply(direction, physics.strength)
            local damping_force = vector.multiply(velocity, physics.air_resistance)
            total_force = vector.add(vector.add(gravity_force, pull_force), damping_force)

            local acceleration = vector.divide(total_force, physics.mass)
            velocity = vector.add(velocity, vector.multiply(acceleration, dtime))
        end
        local on_ground = false
        if moveresult.collides then
            for _, col in ipairs(moveresult.collisions) do
                if col.axis == "y" and velocity.y < 0 then
                    velocity.y = 0
                    on_ground = true
                end
                if col.axis == "x" then
                    velocity.x = 0
                end
                if col.axis == "z" then
                    velocity.z = 0
                end
            end
        end
        -- Apply Friction if on ground
        if on_ground then
            velocity = vector.add(velocity, vector.multiply(vector.subtract(vector.multiply(velocity, vector.new(0,1,0)),velocity),(dtime / physics.friction)))
        end
        -- Stop moving when close to prevent oscilation
        if vector.length(velocity) < 1 and distance < 4 and physics.strength ~= 0 then
            velocity = vector.zero()
        end

        self.object:set_velocity(velocity)
    end,
})

ax_core.enable = function(name)
    local player = core.get_player_by_name(name)
    if not player then return end
    if not ax_core.players[name] then
        ax_core.players[name] = {
            enabled = false
        }
    end
    if not ax_core.players[name].enabled then
        player:hud_set_flags({
            hotbar = false,
            healthbar = false,
            breathbar = false,
            wielditem = false,
            minimap = false,
            crosshair = true
        })
        ax_core.players[name].enabled = true
        local entity = core.add_entity(player:get_pos(), "ax_core:agent")
        if entity then
            entity:get_luaentity().player_name = name
            player:set_attach(entity, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
        end
    else
        player:hud_set_flags({
            hotbar = true,
            healthbar = true,
            breathbar = false,
            wielditem = false,
            minimap = false,
            crosshair = true
        })
        ax_core.players[name].enabled = false
        local entity = player:get_attach()
        player:set_detach()
        if entity then
            entity:remove()
        end
    end
end

-- on_use and on_place
function ax_core.click(itemstack, user, pointed_thing)
    if user then
        local player_name = user:get_player_name()
        if player_name then
            if pointed_thing and pointed_thing.type == "node" then
                local target_position = pointed_thing.under
                if core.get_node(target_position).name == "ax_core:attractor" then
                    ax_core.set_target(player_name, target_position)
                    return nil
                end
            end
            ax_core.set_target(player_name)
        end
    end
    return nil
end

ax_core.set_target = function(name, pos)
    if ax_core.players[name].record then
        local record = ax_core.players[name].record
        if (#record.entries == 0) or
            (pos ~= record.entries[#record.entries].target) or
            (record.entries[#record.entries].target ~= nil and not vector.equals(record.entries[#record.entries].target, pos)) then
            table.insert(record.entries, {
                time = core.get_us_time(),
                target = pos
            })
        end
    end
    ax_core.players[name].target = pos
end

ax_core.start_recording = function(name, params)
    if string.match(params, "^%w+$") == nil then
        return false, "Improper Arguments: 1 arg, alphanumerics only"
    end
    ax_core.players[name].record = {
        name = params,
        time = core.get_us_time(),
        entries = {},
        starting_pos = core.get_player_by_name(name):get_pos()
    }
    return true, "Recording Started."
end

ax_core.stop_recording = function(name)
    if ax_core.players[name].record then
        local record = ax_core.players[name].record
        table.insert(record.entries, {
            time = core.get_us_time(),
            target = nil
        })
        local recording_name = record.name
        for i=1, #record.entries, 1 do
            record.entries[i].time = (record.entries[i].time - record.time) / 1000000 -- microseconds -> seconds
        end
        ax_core.recordings[recording_name] ={
            entries = table.copy(record.entries),
            starting_pos = vector.copy(record.starting_pos)
        } 
        ax_core.players[name].record = nil
        return true, "Recording '" .. recording_name .. "' saved with " .. #record.entries .. " entries."
    else
        return false, "No current recording to stop"
    end
end

ax_core.play_recording = function(params)
    if string.match(params, "^%w+$") == nil then
        return false, "Improper Arguments: 1 arg, alphanumerics only"
    end
    if ax_core.recordings[params] == nil then
        return false, "No Recording '" .. params .. "' Found."
    end
    local entity = core.add_entity(ax_core.recordings[params].starting_pos, "ax_core:agent")
    if entity then
        entity:get_luaentity().recording = {
            index = 1,
            time = 0,
            entries = table.copy(ax_core.recordings[params].entries),
        }
        return true
    else
        return false, "Couldn't Create Playback Entity!!"
    end
end

core.register_tool("ax_core:gun", {
	description = "Agent X Gun",
	inventory_image = "default_cobble.png", -- Placeholder image
	range = 256,
	full_punch_interval = 0.2,
	on_use = ax_core.click,
	on_place = ax_core.click,
	on_secondary_use = ax_core.click,
})

core.register_node("ax_core:attractor", {
    description = "Attractor",
    tiles = {"default_cobble.png^[colorize:blue:255"},
    is_ground_content = true,
    groups = {oddly_breakable_by_hand=1}
})

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

core.register_chatcommand("start",
{
    params = "<recording name>",
    description = "Start AX Recording",
    privs = {},
    func = function(name, params)
        return ax_core.start_recording(name, params)
    end
})

core.register_chatcommand("stop",
{
    params = "",
    description = "Stop Current AX Recording",
    privs = {},
    func = function(name, params)
        return ax_core.stop_recording(name)
    end
})

core.register_chatcommand("play",
{
    params = "<recording name>",
    description = "Playback AX Recording",
    privs = {},
    func = function(name, params)
        return ax_core.play_recording(params)
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

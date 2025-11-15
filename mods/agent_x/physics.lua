ax_core.players = {}
ax_core.physics = {
    strength = 100,
    mass = 5,
    air_resistance = -8,
    gravity = -5,
    friction = 0.2,
}
ax_core.replays = {}

ax_core.agent_properties = {
    initial_properties = {
        physical = true,
        collide_with_objects = false,
        pointable = false,
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        visual = "sprite",
        textures = {"agent_x.png"}
    },

    on_activate = function(self, staticdata)
        self.object:set_armor_groups({immortal = 1})
    end,

    static_save = false,

    on_step = function(self, dtime, moveresult)
        local player_data = {}
        if self.player_name then
            player_data = ax_core.players[self.player_name]
        elseif self.replay then
            local replay = self.replay
            replay.time = replay.time + dtime
            while replay.time > replay.entries[replay.index].time do
                replay.index = replay.index + 1
                if replay.index > #replay.entries then
                    self.object:remove()
                    return
                end
            end
            player_data = {
                target = replay.entries[replay.index].target
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
}

core.register_entity("ax_core:agent", ax_core.agent_properties)

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
        local entity = core.add_entity(vector.add(player:get_pos(), vector.new(0,0.5,0)), "ax_core:agent")
        if entity then
            entity:get_luaentity().player_name = name
            player:set_attach(entity, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
            --player:set_eye_offset(vector.new(0,-10,0))
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
    if ax_core.players[name].replay then
        local replay = ax_core.players[name].replay
        if (#replay.entries == 0) or
            (pos ~= replay.entries[#replay.entries].target) or
            (replay.entries[#replay.entries].target ~= nil and not vector.equals(replay.entries[#replay.entries].target, pos)) then
            table.insert(replay.entries, {
                time = core.get_us_time(),
                target = pos
            })
        end
    end
    ax_core.players[name].target = pos
end

core.register_tool("ax_core:gun", {
	description = "Agent X Gun",
	inventory_image = "glow_red.png", -- Placeholder image
	range = 256,
	full_punch_interval = 0.2,
	on_use = ax_core.click,
	on_place = ax_core.click,
	on_secondary_use = ax_core.click,
})

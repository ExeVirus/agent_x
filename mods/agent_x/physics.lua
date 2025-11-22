ax_core.players = {}
ax_core.physics = {
    strength = 0,
    mass = 1,
    air_resistance = -1.5,
    gravity = -12,
    friction = 0.2,
}

ax_core.agent_properties = {
    initial_properties = {
        physical = true,
        collide_with_objects = true,
        pointable = false,
        collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
        visual = "mesh",
        mesh = "agent.obj",
        textures = {"invisible.png"},
        automatic_face_movement_dir = 0,
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
            while #replay.entries >= replay.index+1 and replay.time > replay.entries[replay.index+1].time do
                replay.index = replay.index + 1
            end
            if replay.index == #replay.entries and replay.time > replay.entries[replay.index].time then
                if replay.loop then
                    replay.index = 1
                    replay.time = 0
                    self.object:set_pos(replay.starting_pos)
                    self.object:set_velocity(vector.zero())
                else
                    self.object:remove()
                    return
                end
            end
            player_data = {
                target = replay.entries[replay.index].target,
                strength = replay.entries[replay.index].strength
            }
        else
            self.object:remove()
            return
        end
        local physics = ax_core.physics

        -- If we don't have a player or target, do nothing.
        local velocity = self.object:get_velocity()
        local distance = 100
        local current_pos = self.object:get_pos()
        if not player_data or not player_data.target then
            -- Apply basic gravity if there's no target active
            velocity.y = velocity.y + (physics.gravity * dtime)
            self.object:set_velocity(velocity)
        else
            -- Physics Model
            local target_pos = player_data.target
            local target_strength = player_data.strength
            local vector_to_target = vector.subtract(target_pos, current_pos)
            distance = vector.length(vector_to_target)
            
            -- To prevent division by zero if we are exactly at the target
            if distance < 0 then
                self.object:set_velocity(velocity)
                return
            end
            local direction = vector.normalize(vector_to_target)
            local gravity_force = vector.new(0, physics.mass * physics.gravity, 0)
            local pull_force = vector.multiply(direction, target_strength)
            local damping_force = vector.multiply(velocity, physics.air_resistance)
            total_force = vector.add(vector.add(gravity_force, pull_force), damping_force)

            local acceleration = vector.divide(total_force, physics.mass)
            velocity = vector.add(velocity, vector.multiply(acceleration, dtime))

            -- beam effect
            ax_core.beam(current_pos, target_pos)
        end
        local on_ground = false
        if moveresult.collides then
            for _, col in ipairs(moveresult.collisions) do
                if col.type == "node" and core.get_node(col.node_pos).name == "ax_core:field" then
                    core.sound_play("lava",{gain=ax_core.volume.effects/100}, true)
                    ax_core.lava_particles(current_pos)
                    if self.replay then
                        self.object:remove()
                        return
                    elseif self.player_name then
                        -- revert to last enabled position
                        self.object:set_pos(player_data.enabled_pos)
                        local player = core.get_player_by_name(self.player_name)
                        player:set_look_vertical(player_data.enabled_look_vertical)
                        player:set_look_horizontal(player_data.enabled_look_horizontal)
                        self.object:set_velocity(vector.zero())
                        return
                    end
                end
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
        if vector.length(velocity) < 1 and distance < 2 then
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
        local stack = ItemStack("ax_core:gun")
        player:get_inventory():set_list("main", {stack})
        player:set_wielded_item(stack)
        player:hud_set_flags({
            hotbar = false,
            healthbar = false,
            breathbar = false,
            wielditem = false,
            minimap = false,
            crosshair = true
        })
        ax_core.players[name].enabled = true
        ax_core.players[name].enabled_pos = player:get_pos()
        ax_core.players[name].enabled_look_vertical = player:get_look_vertical()
        ax_core.players[name].enabled_look_horizontal = player:get_look_horizontal()
        local entity = core.add_entity(vector.add(player:get_pos(), vector.new(0,0.1,0)), "ax_core:agent")
        if entity then
            entity:get_luaentity().player_name = name
            player:set_attach(entity, "", {x=0, y=0, z=0}, {x=0, y=90, z=0})
        end
    end
end

ax_core.disable = function(name)
    local player = core.get_player_by_name(name)
    if not player then return end
    if not ax_core.players[name] then
        ax_core.players[name] = {
            enabled = false
        }
    end
    if ax_core.players[name].enabled then
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
                local target_start_string = "ax_core:target_"
                local node_name = core.get_node(target_position).name
                local is_target = node_name:sub(1, #target_start_string) == target_start_string
                if is_target then
                    ax_core.set_target(player_name, target_position, node_name:sub(#target_start_string + 1))
                    return nil
                end
            end
            ax_core.set_target(player_name)
        end
    end
    return nil
end

ax_core.set_target = function(name, pos, target_name)
    local strength_values = {
        attractor = 40,
        weak_attractor = 20,
        repulsor = -20,
    }
    local strength = strength_values[target_name]

    if ax_core.players[name].replay then
        local replay = ax_core.players[name].replay
        if (#replay.entries == 0) or
            (pos ~= replay.entries[#replay.entries].target) or
            (replay.entries[#replay.entries].target ~= nil and not vector.equals(replay.entries[#replay.entries].target, pos)) then
            table.insert(replay.entries, {
                time = core.get_us_time(),
                target = pos,
                strength = strength
            })
        end
    end
    if (pos ~= nil and not ax_core.players[name].target) or 
       (ax_core.players[name].target and pos and not vector.equals(ax_core.players[name].target,pos)) then
        core.sound_play("target",{gain=ax_core.volume.effects/100}, true)
    elseif pos == nil and ax_core.players[name].target ~= nil then
        core.sound_play("untarget",{gain=ax_core.volume.effects/100}, true)
    end
    ax_core.players[name].target = pos
    ax_core.players[name].strength = strength
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

--------------------------------------------------
--  Node Definitions
--------------------------------------------------

local groups = {}

if ax_core.buildMode then
    groups = { oddly_breakable_by_hand=1 }
    core.override_item("", {
        tool_capabilities = {
            full_punch_interval = 0.1,
            max_drop_level = 0,
            groupcaps = { oddly_breakable_by_hand = {times={[1]=0.1}, uses=0} 
        }
    }})
end

local function reg_node(name, extra_fields)
    core.register_node("ax_core:"..name, table.merge({
        description = name,
        tiles = {name..".png"},
        groups = groups,
        diggable = ax_core.buildMode,
        pointable = ax_core.buildMode,
    }, extra_fields or {}))
end

-- Basic Building Blocks
reg_node("floor_1")
reg_node("floor_2")
reg_node("floor_3")
reg_node("wall_1")
reg_node("wall_2")
reg_node("wall_3")
reg_node("light_panel", {
    paramtype = "light",
    light_source = 14,
})
reg_node("cage", {
    drawtype="airlike",
    paramtype = "none",
    tiles = {},
})
reg_node("target_attractor", {
    tiles = {"glow_red.png^[colorize:blue:255"},
    light_source = 9,
    pointable = true,
})
reg_node("target_weak_attractor", {
    tiles = {"glow_red.png^[colorize:blue:120"},
    light_source = 9,
    pointable = true,
})
reg_node("target_repulsor", {
    tiles = {"glow_red.png"},
    light_source = 9,
    pointable = true,
})
ax_core.lights = {}
local function makeAirLightNode(name, brightness)
    table.insert(ax_core.lights, name)
    reg_node(name, {
        drawtype="airlike",
        paramtype = "light",
        light_source = brightness,
        tiles = {},
        walkable = false,
    })
end
makeAirLightNode("dark",    2)
makeAirLightNode("dim",     4)
makeAirLightNode("light",   9)
makeAirLightNode("bright", 13)

-- Neon Light Strips
ax_core.neons = {
    colors = {},
    shapes = {"strip_", "right_", "left_", "3way_", "4way_"},
}
local function make_neon(color)
    table.insert(ax_core.neons.colors, color)
    local defaults = {
        tiles = {"glow_"..color..".png"},
        drawtype = "nodebox",
        light_source = 14,
        paramtype2 = "facedir",
    }
    reg_node("strip_" .. color, table.merge(defaults, {
        node_box = {
            type = "fixed",
            fixed = {-0.1, -0.5, -0.5, 0.1, -0.3, 0.5},
        }
    }))
    reg_node("right_" .. color, table.merge(defaults, {
        node_box = {
            type = "fixed",
            fixed = {
                {-0.1, -0.5, -0.5, 0.1, -0.3, 0.1},
                { 0.1, -0.5, -0.1, 0.5, -0.3, 0.1},
            }
        }
    }))
    reg_node("left_" .. color, table.merge(defaults, {
        node_box = {
            type = "fixed",
            fixed = {
                {-0.1, -0.5, -0.5,  0.1, -0.3, 0.1},
                {-0.5, -0.5, -0.1, -0.1, -0.3, 0.1},
            }
        }
    }))
    reg_node("3way_" .. color, table.merge(defaults, {
        node_box = {
            type = "fixed",
            fixed = {
                {-0.1, -0.5, -0.5,  0.1, -0.3, -0.1},
                {-0.5, -0.5, -0.1,  0.5, -0.3, 0.1},
            }
        }
    }))
    reg_node("4way_" .. color, table.merge(defaults, {
        node_box = {
            type = "fixed",
            fixed = {
                {-0.1, -0.5, -0.5,  0.1, -0.3, 0.5},
                {-0.5, -0.5, -0.1,  0.5, -0.3, 0.1},
            }
        }
    }))
end
make_neon("red")
make_neon("blue")
make_neon("green")
make_neon("yellow")
make_neon("orange")
make_neon("purple")
make_neon("pink")

ax_core.cage_neons = function(x,y,z,x2,y2,z2)
    -- 1. Sort positions to ensure p1 is the min corner and p2 is the max corner.
    local min = vector.new(
        math.min(x, x2),
        math.min(y, y2),
        math.min(z, z2)
    )
    local max = vector.new(
        math.max(x, x2),
        math.max(y, y2),
        math.max(z, z2)
    )

    -- 2. Get the VoxelManip for the region.
    local manip = VoxelManip(min, max)
    local emin, emax = manip:get_emerged_area()
    -- Create a VoxelArea that corresponds to the actual loaded region.
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = manip:get_data()

    -- 3. Get the content IDs for fast comparison.
    local search_ids = {}
    for i=1,#ax_core.lights do
        table.insert(search_ids, core.get_content_id("ax_core:" .. ax_core.lights[i]))
    end
    local replace_id = core.get_content_id("ax_core:cage")
    local near_ids = {}
    for i=1,#ax_core.neons.colors do
        for j=1, #ax_core.neons.shapes do
            table.insert(near_ids, core.get_content_id("ax_core:" .. ax_core.neons.shapes[j] .. ax_core.neons.colors[i]))
        end
    end

    -- A table of relative offsets for all 6 adjacent nodes.
    local neighbor_offsets = {
        {x = -1, y =  0, z =  0}, -- Left
        {x =  1, y =  0, z =  0}, -- Right
        {x =  0, y = -1, z =  0}, -- Down
        {x =  0, y =  1, z =  0}, -- Up
        {x =  0, y =  0, z = -1}, -- Back
        {x =  0, y =  0, z =  1}  -- Forward
    }

    -- 4. Iterate through the entire data array.
    for i = 1, #data do
        -- Search any matching light nodes
        local found_search = false
        for j = 1, #search_ids do
            if data[i] == search_ids[j] then
                found_search = true
                break
            end
        end
        if found_search then
            -- Get the 3D position of the current node (using a 0-based index).
            local pos = area:position(i - 1)
            local found_near = false

            -- Check all 6 neighbors.
            for _, offset in ipairs(neighbor_offsets) do
                local neighbor_pos = {
                    x = pos.x + offset.x,
                    y = pos.y + offset.y,
                    z = pos.z + offset.z,
                }

                -- Check if the neighbor is within the loaded area bounds.
                if area:contains(neighbor_pos.x, neighbor_pos.y, neighbor_pos.z) then
                    local neighbor_index = area:index(neighbor_pos.x, neighbor_pos.y, neighbor_pos.z)
                    for i=1,#near_ids do
                        if data[neighbor_index + 1] == near_ids[i] then
                            found_near = true
                            break
                        end
                    end
                end
            end

            -- If a valid neighbor was found, perform the replacement.
            if found_near then
                data[i] = replace_id
            end
        end
    end

    -- 5. Apply the changes back to the world.
    manip:set_data(data)
    manip:write_to_map(true)
end
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
reg_node("attractor", {
    tiles = {"glow_red.png^[colorize:blue:255"},
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
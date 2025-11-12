--------------------------------------------------
--  Node Definitions
--------------------------------------------------

local groups = {}
if ax_core.buildMode then
    groups = { oddly_breakable_by_hand=1 }
end

core.override_item("", {
    wield_scale = {x=1,y=1,z=1},
    tool_capabilities = {
        full_punch_interval = 0.5,
        max_drop_level = 0,
        groupcaps = {
            oddly_breakable_by_hand = {times={[1]=0.5}, uses=0}
        }
    }
})

core.register_node("ax_core:floor_1", {
    description = "Floor 1",
    tiles = {"floor_1.png"},
    sunlight_propagates = false,
    groups = {oddly_breakable_by_hand=1},
    diggable = ax_core.buildMode,
    pointable = ax_core.buildMode,
})
core.register_node("ax_core:floor_2", {
    description = "Floor 2",
    tiles = {"floor_2.png"},
    sunlight_propagates = false,
    groups = {oddly_breakable_by_hand=1},
    diggable = ax_core.buildMode,
    pointable = ax_core.buildMode,
})
core.register_node("ax_core:floor_3", {
    description = "Floor 3",
    tiles = {"floor_3.png"},
    sunlight_propagates = false,
    groups = groups,
    diggable = ax_core.buildMode,
    pointable = ax_core.buildMode,
})
core.register_node("ax_core:wall_1", {
    description = "Wall 1",
    tiles = {"wall_1.png"},
    sunlight_propagates = false,
    groups = groups,
    diggable = ax_core.buildMode,
    pointable = ax_core.buildMode,
})
core.register_node("ax_core:wall_2", {
    description = "Wall 2",
    tiles = {"wall_2.png"},
    sunlight_propagates = false,
    groups = groups,
    diggable = ax_core.buildMode,
    pointable = ax_core.buildMode,
})
core.register_node("ax_core:wall_3", {
    description = "Wall 3",
    tiles = {"wall_3.png"},
    sunlight_propagates = false,
    groups = groups,
    diggable = ax_core.buildMode,
    pointable = ax_core.buildMode,
})
core.register_node("ax_core:light_panel", {
    description = "Light Panel",
    tiles = {"light_panel.png"},
    sunlight_propagates = false,
    paramtype = "light",
    groups = groups,
    light_source = 14,
    diggable = ax_core.buildMode,
    pointable = ax_core.buildMode,
})
core.register_node("ax_core:cage", {
    description = "Light Cage",
    -- tiles = {"invisible.png"},
    sunlight_propagates = false,
    drawtype="airlike",
    paramtype = "none",
    use_texture_alpha = "clip",
    groups = groups,
    diggable = ax_core.buildMode,
    pointable = ax_core.buildMode,
})

local function makeStrip(color)
    core.register_node("ax_core:strip_" .. color, {
        description = "Neon Strip" .. color,
        tiles = {"glow_"..color..".png"},
        drawtype = "nodebox",
        sunlight_propagates = false,
        groups = groups,
        light_source = 14,
        diggable = ax_core.buildMode,
        pointable = ax_core.buildMode,
        paramtype2 = "facedir",
        node_box = {
            type = "fixed",
            fixed = {-0.1, -0.5, -0.5, 0.1, -0.3, 0.5},
        }
    })
end

makeStrip("red")
makeStrip("blue")
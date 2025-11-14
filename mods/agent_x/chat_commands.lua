
------
--Super Special helper chat command for neons, cages them correctly
------
if ax_core.buildMode then
    local function cage_neons(x,y,z,x2,y2,z2)
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
                    cage_neons(unpack(parts))
                else
                    return nil, "Invalid numeric value in params: " .. params
                end
            else
                return nil, "Needs 6 arguments: " .. params
            end
        end
    })
end

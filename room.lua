args = { ... }

-- Configurable room dimensions
local width = tonumber(args[1]) or 5
local depth = tonumber(args[2]) or 5
local height = tonumber(args[3]) or 5

if width < 3 or depth < 3 or height < 3 then
    error("Room dimensions must be at least 3x3x3")
end
print("Mining a " .. width .. "x" .. depth .. "x" .. height .. " room")

-- Load libraries
require("libdata")
require("libstate")
require("libinventory")
require("libmove")

-- Get the building material from the first slot
turtle.select(1)
local buildingMaterial = turtle.getItemDetail()
if not buildingMaterial then
    error("No building material in the first slot!")
end

-- Function to mine a block and place a new one
function mineAndReplace(direction)
    -- Mine the block
    Dig(direction)

    -- Place the new block
    SelectItem(buildingMaterial.name)
    Place(direction)
end

-- Mine out the room and build the walls and floor
for z = 1, height do
    for y = 1, depth do
        for x = 1, width do
            -- Mine forward
            if x < width then
                Dig(FORWARD)
            end

            -- Mine up
            if z < height then
                Dig(UP)
            end

            -- Build floor
            if z == 1 then
                SelectItem(buildingMaterial.name)
                Place(DOWN)
            end

            -- Build walls
            if y == 1 then
                SelectItem(buildingMaterial.name)
                Place(LEFT)
            end
            if y == depth then
                SelectItem(buildingMaterial.name)
                Place(RIGHT)
            end
            if x == 1 then
                SelectItem(buildingMaterial.name)
                Place(BACK)
            end
            if x == width then
                SelectItem(buildingMaterial.name)
                Place(FORWARD)
            end

            -- Move to the next position
            if x < width then
                Move(1, 0, 0)
            end
        end

        -- Move to the next row
        if y < depth then
            Move(-width + 1, 1, 0)
        end
    end

    -- Move to the next level
    if z < height then
        Move(0, -depth + 1, 1)
    end
end

-- Return to the starting position
ReturnHome()

print("Room mining complete!")

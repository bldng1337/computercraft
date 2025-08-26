local args = { ... }

local width = tonumber(args[1]) or 5
local depth = tonumber(args[2]) or 5
local height = tonumber(args[3]) or 5

if width < 3 or depth < 3 or height < 3 then
    error("Room dimensions must be at least 3x3x3")
end
print("Mining a " .. width .. "x" .. depth .. "x" .. height .. " room")

require("libdata")
require("libstate")
require("libinventory")
require("libmove")
ShouldCheckForWorth = false

local buildingMaterial = GetItem(1)
if not buildingMaterial then
    error("No building material in the first slot!")
end


local startpoint = Vec3.new(0, -(width / 2), 0):floor()
local endpoint = Vec3.new(depth, width / 2, height):ceil()
print("Starting at " .. startpoint.x .. ", " .. startpoint.y .. ", " .. startpoint.z)
print("Ending at " .. endpoint.x .. ", " .. endpoint.y .. ", " .. endpoint.z)
for z = startpoint.z, endpoint.z do
    for y = startpoint.y, endpoint.y do
        local yedge = (y == startpoint.y) or (y == endpoint.y)
        for x = startpoint.x, endpoint.x do
            local xedge = (x == startpoint.x) or (x == endpoint.x)
            local pos = Vec3.new(x, y, z)
            print("Mining " .. pos.x .. ", " .. pos.y .. ", " .. pos.z)
            local prev = GetPosition()
            Moveto(pos)
            if (xedge or yedge) or z == startpoint.z then
                Dig(DOWN)
                SelectItem(buildingMaterial.name)
                Place(DOWN)
            end
            if z == endpoint.z and not (xedge or yedge) then
                Dig(UP)
                SelectItem(buildingMaterial.name)
                Place(UP)
            end
            if z == endpoint.z and (xedge or yedge) then
                local delta = prev - pos
                local dir = VecToDir(delta)
                Dig(dir)
                SelectItem(buildingMaterial.name)
                Place(dir)
            end
        end
    end
end

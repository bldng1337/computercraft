require("libdata")
require("libstate")
require("libinventory")

function HandleResume()
    if GetReturning() then
        ReturnHome()
    end
    if GetVeinMining() then
        Moveto(GetVeinInitialPos())
        SetVeinMining(false)
    end
    print("Resuming Operation")
end

GetPosition, SetPosition = UseState("Position", Vec3.new(0, 0, 0))
GetFacing, SetFacing = UseState("Facing", 0)
FORWARD = 0
RIGHT = 1
BACK = 2
LEFT = 3
DOWN = 4
UP = 5

function DirToString(dir)
    if dir == UP then
        return "UP"
    elseif dir == DOWN then
        return "DOWN"
    elseif dir == FORWARD then
        return "FORWARD"
    elseif dir == BACK then
        return "BACK"
    elseif dir == LEFT then
        return "LEFT"
    elseif dir == RIGHT then
        return "RIGHT"
    end
    return "UNKNOWN"
end

function DirToVec(dir)
    if dir == UP then
        return Vec3.new(0, 0, 1)
    elseif dir == DOWN then
        return Vec3.new(0, 0, -1)
    elseif dir == FORWARD then
        return Vec3.new(1, 0, 0)
    elseif dir == BACK then
        return Vec3.new(-1, 0, 0)
    elseif dir == LEFT then
        return Vec3.new(0, -1, 0)
    elseif dir == RIGHT then
        return Vec3.new(0, 1, 0)
    end
end

function VecToDir(vec)
    if vec.x > 0 and vec.y == 0 and vec.z == 0 then
        return FORWARD;
    end
    if vec.x < 0 and vec.y == 0 and vec.z == 0 then
        return BACK;
    end
    if vec.x == 0 and vec.y < 0 and vec.z == 0 then
        return LEFT;
    end
    if vec.x == 0 and vec.y > 0 and vec.z == 0 then
        return RIGHT;
    end
    return GetFacing()
end

function GetMoveDir(mx, my)
    return VecToDir(Vec3.new(mx, my, 0))
end

function Rotate(dir)
    if dir == UP or dir == DOWN then
        return
    end
    while not (dir == GetFacing()) do
        if dir == 0 and GetFacing() == 3 then
            turtle.turnLeft()
            SetFacing(3)
        elseif dir == 3 and GetFacing() == 0 then
            turtle.turnRight()
            SetFacing(0)
        end
        if dir < GetFacing() then
            turtle.turnLeft()
            SetFacing(GetFacing() - 1)
        else
            turtle.turnRight()
            SetFacing(GetFacing() + 1)
        end
    end
end

function Move(mx, my, mz, destructive)
    destructive = destructive or true
    local function mv(z)
        local function step()
            if z == "UP" then
                return turtle.up()
            elseif z == "DOWN" then
                return turtle.down()
            elseif z == "FORWARD" then
                return turtle.forward()
            end
        end
        local function Dig()
            if z == "UP" then
                turtle.digUp()
                turtle.attackUp()
            elseif z == "DOWN" then
                turtle.digDown()
                turtle.attackDown()
            elseif z == "FORWARD" then
                turtle.dig()
                turtle.attack()
            end
        end

        while not step() do
            if destructive then
                Dig()
            end
            sleep(0.1)
        end
        CheckReturn()
        if not GetReturning() then
            CheckForWorth(GetFacing())
            CheckForWorth(UP)
            CheckForWorth(DOWN)
        end
    end

    if not (mx == 0) then
        Rotate(GetMoveDir(mx, 0))
        local dist = math.abs(mx);
        while not (dist == 0) do
            dist = dist - 1;
            mv("FORWARD")
            SetPosition(GetPosition() + Vec3.new(sign(mx), 0, 0))
        end
    end
    if not (my == 0) then
        Rotate(GetMoveDir(0, my))
        local dist = math.abs(my);
        while not (dist == 0) do
            dist = dist - 1;
            mv("FORWARD")
            SetPosition(GetPosition() + Vec3.new(0, sign(my), 0))
        end
    end
    if not (mz == 0) then
        Rotate(GetMoveDir(0, 0))
        local dist = math.abs(mz);
        while not (dist == 0) do
            if mz < 0 then
                mv("DOWN")
            else
                mv("UP")
            end
            dist = dist - 1;
            SetPosition(GetPosition() + Vec3.new(0, 0, sign(mz)))
        end
    end
end

function Moveto(vec)
    local pos = GetPosition()
    Move(vec.x - pos.x, vec.y - pos.y, vec.z - pos.z)
end

function Place(dir)
    if dir == UP then
        return turtle.placeUp()
    elseif dir == DOWN then
        return turtle.placeDown()
    else
        Rotate(dir)
        return turtle.place()
    end
end

function Dig(dir)
    if dir == UP then
        return turtle.digUp()
    elseif dir == DOWN then
        return turtle.digDown()
    else
        Rotate(dir)
        return turtle.dig()
    end
end

GetReturning, SetReturning = UseState("Returning", false)

function GetFuel()
    if turtleNeedFuel == 0 then
        return 99999
    end
    local fuel = turtle.getFuelLevel()
    if fuel < turtle.getFuelLimit() then
        turtle.refuel(1)
    end
    return fuel
end

function HasEnoughFuel()
    local pos = GetPosition()
    local fuel = GetFuel()
    local dist = (pos.x + pos.y + pos.z) + 100
    if dist > fuel then
        return false
    end
    return true
end

function CheckReturn()
    if not HasEnoughFuel() then
        print("Not enough fuel Returning")
        ReturnHome()
        error("Ran out of fuel")
    end
end

function ReturnHome()
    SetReturning(true)
    Moveto(Vec3.new(0, 0, 0))
end

GetVeinMining, SetVeinMining = UseState("VeinMining", false)
GetVeinInitialPos, SetVeinInitialPos = UseState("VeinInitialPos", Vec3.new(0, 0, 0))
GetVeinInitialDir, SetVeinInitialDir = UseState("VeinInitialDir", 0)
ToVeinMine = Set.new()

function Inspect(dir)
    if dir == UP then
        local has, block = turtle.inspectUp()
        if not has then
            return nil
        end
        return block
    elseif dir == DOWN then
        local has, block = turtle.inspectDown()
        if not has then
            return nil
        end
        return block
    else
        Rotate(dir)
        local has, block = turtle.inspect()
        if not has then
            return nil
        end
        return block
    end
end

function CheckBlockWorth(block, tocheck)
    tocheck = tocheck or ToVeinMine
    if block == nil then
        return false
    end
    for v in tocheck:elements() do
        if type(v) == "string" then
            if string.find(block["name"], v) then
                return true
            end
        else
            if v:matches(block) then
                return true
            end
        end
    end
    return false
end

function IsChest(block)
    if block == nil then
        return false
    end
    if block["name"] == nil then
        return false
    end
    return string.find(block["name"], "chest")
end

function CheckForWorth(dir)
    local block = Inspect(dir)
    if block == nil then
        return
    end
    if IsChest(block) then
        LootChest(dir)
        return
    end
    if block == "lava" and block.state.level == 0 then
        if SelectItem("bucket") then
            Place(dir)
            turtle.refuel(1)
        end
        return
    end
    if GetVeinMining() then
        return
    end
    if CheckBlockWorth(block) then
        Veinmine(dir, ToVeinMine)
    end
end

local alldirs = {
    DirToVec(DOWN),
    DirToVec(UP),
    DirToVec(FORWARD),
    DirToVec(RIGHT),
    DirToVec(BACK),
    DirToVec(LEFT),
}

function Veinmine(dir, tomine)
    if GetVeinMining() then
        return
    end
    print("Starting Veinmine")
    local initpos = GetPosition()
    local initdir = GetFacing()
    SetVeinInitialPos(initpos)
    SetVeinInitialDir(initdir)
    SetVeinMining(true)
    local stack = Stack.new()
    local checked = Set.new()
    stack:push(DirToVec(dir) + initpos)
    while not stack:isEmpty() do
        local vec = stack:pop()
        if vec == nil then
            break
        end
        print("Moving to " .. vec.x .. ", " .. vec.y .. ", " .. vec.z)
        Moveto(vec)
        print("Checking...")
        for i, v in ipairs(alldirs) do
            local dir = VecToDir(v)
            local pos = GetPosition() + v
            if checked:contains(pos) then
                print("Skipping " .. DirToString(dir))
            end
            if not checked:contains(pos) then
                checked:add(pos)
                if CheckBlockWorth(Inspect(dir), tomine) then
                    print("Pushing " .. DirToString(dir))
                    stack:push(pos)
                end
            end
        end
    end
    print("Finished Veinmine")
    Moveto(GetVeinInitialPos())
    SetFacing(GetVeinInitialDir())
    SetVeinMining(false)
end

-- Inventory


if Resumed then
    HandleResume()
end

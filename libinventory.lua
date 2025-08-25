ToClear = Set.new()
Keep = Set.new()

function ShouldKeep(item)
    for keep in Keep:elements() do
        if type(keep) == "string" then
            if string.find(item["name"], keep) then
                return true
            end
        else
            if keep:matches(item) then
                return true
            end
        end
    end
    return false
end

function ShouldClear(item)
    for clear in ToClear:elements() do
        if type(clear) == "string" then
            if string.find(item["name"], clear) then
                return true
            end
        else
            if clear:matches(item) then
                return true
            end
        end
    end
    return false
end

function LootChest(dir)
    if dir == UP then
        while turtle.suckUp() do end
    elseif dir == DOWN then
        while turtle.suckDown() do end
    else
        Rotate(dir)
        while turtle.suck() do end
    end
end

function Deposit(dir)
    Rotate(dir)
    local block = Inspect(dir)
    if not IsChest(block) then
        print("Have not found a chest")
        return false
    end
    for i = 1, 16 do
        if not ShouldKeep(turtle.getItemDetail(i)) then
            turtle.select(i)
            while turtle.drop() == false and turtle.getItemCount() ~= 0 do -- Waits until turtle can deposit item
                sleep(0.1)
            end
            turtle.drop()
        end
    end
    turtle.select(1)
    return true
end

function IsInvFull()
    local full = true
    for i = 1, 16 do
        local count = turtle.getItemCount(i)
        if count == 0 then
            full = false
        end
    end
    return full
end

function ClearInv()
    for i = 1, 16 do
        while turtle.getItemCount(i) > 0 do
            local item = GetItem(i)
            if ShouldClear(item) then
                turtle.select(i)
                turtle.drop()
            end
        end
    end
    return IsInvFull()
end

function GetItem(i)
    return turtle.getItemDetail(i)
end

function CheckInv()
    if not IsInvFull() then
        return
    end
    print("Inventory is full")
    ClearInv()
end

function SelectItem(name)
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            if type(name) == "string" then
                if string.find(turtle.getItemDetail(i)["name"], name) then
                    turtle.select(i)
                    return true
                end
            else
                if name:matches(turtle.getItemDetail(i)) then
                    turtle.select(i)
                    return true
                end
            end
        end
    end
    return false
end

ItemMatcher = {}
ItemMatcher.__index = ItemMatcher

function ItemMatcher.newName(name)
    local self = {
        type = "name",
        name = name
    }
    return setmetatable(self, ItemMatcher)
end

function ItemMatcher.newTag(tag)
    local self = {
        type = "tag",
        tag = tag
    }
    return setmetatable(self, ItemMatcher)
end

function ItemMatcher:matches(item)
    if self.type == "name" then
        if string.find(item["name"], self.name) then
            return true
        end
    end
    if self.type == "tag" then
        if item["tags"][self.tag] then
            return true
        end
    end
    return false
end

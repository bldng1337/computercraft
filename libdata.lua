if LibData then
    return
end
LibData = true

Vec3 = {}
Vec3.__index = Vec3

-- The constructor for a new Vec3 object.
-- @param x The x-component (number).
-- @param y The y-component (number).
-- @param z The z-component (number).
-- @return A new Vec3 object.
function Vec3.new(x, y, z)
    -- Create a new table for the vector.
    local newVec = {
        x = x or 0,
        y = y or 0,
        z = z or 0
    }
    -- Set its metatable to the Vec3 type, allowing it to
    -- inherit methods and use operator overloading.
    return setmetatable(newVec, Vec3)
end

-- Metamethod for the addition operator (+).
-- This is called when you use the '+' operator on two Vec3 objects.
-- @param a The first vector.
-- @param b The second vector.
-- @return A new vector that is the sum of the two.
function Vec3.__add(a, b)
    return Vec3.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

-- Metamethod for converting the vector to a string.
-- This is useful for printing the vector's values.
-- @param v The vector to be converted.
-- @return A formatted string representation of the vector.
function Vec3.__tostring(v)
    return string.format("Vec3(x:%.2f, y:%.2f, z:%.2f)", v.x, v.y, v.z)
end

function Vec3:serialize(v)
    return { typeid = "vec3", x = v.x, y = v.y, z = v.z }
end

function Vec3:manhattan(other)
    if other == nil then
        return math.abs(self.x) + math.abs(self.y) + math.abs(self.z)
    end
    return math.abs(other.x - self.x) + math.abs(other.y - self.y) + math.abs(other.z - self.z)
end

Stack = {}
Stack.__index = Stack

--[[
  Creates and returns a new Stack object.
  This is the constructor function.
]]
function Stack.new()
    local self = {
        -- The internal data storage for the stack.
        -- We use a table to hold the elements.
        data = {}
    }
    -- Set up the metatable so that new instances can use the Stack methods.
    return setmetatable(self, Stack)
end

--[[
  Adds an element to the top of the stack.
  @param self The Stack object instance.
  @param element The element to add to the stack.
]]
function Stack:push(element)
    -- The # operator gets the number of elements in the table (size).
    -- We add the new element at the next available index.
    self.data[#self.data + 1] = element
end

--[[
  Removes and returns the element at the top of the stack.
  Returns nil if the stack is empty.
  @param self The Stack object instance.
  @return The element that was removed, or nil.
]]
function Stack:pop()
    if self:isEmpty() then
        return nil
    end
    -- Get the current top element.
    local topElement = self.data[#self.data]
    -- Remove the top element from the table.
    self.data[#self.data] = nil
    return topElement
end

--[[
  Returns the element at the top of the stack without removing it.
  Returns nil if the stack is empty.
  @param self The Stack object instance.
  @return The top element, or nil.
]]
function Stack:peek()
    if self:isEmpty() then
        return nil
    end
    -- Simply return the element at the top.
    return self.data[#self.data]
end

--[[
  Checks if the stack is empty.
  @param self The Stack object instance.
  @return true if the stack is empty, false otherwise.
]]
function Stack:isEmpty()
    -- The stack is empty if its size is 0.
    return #self.data == 0
end

--[[
  Returns the number of elements currently in the stack.
  @param self The Stack object instance.
  @return The size of the stack.
]]
function Stack:size()
    return #self.data
end

function Stack:serialize()
    local data = self.data.map(function(v)
        if v.serialize then
            return v.serialize()
        end
        return v
    end)
    return { typeid = "stack", data = table.concat(data, ",") }
end

--- Set.lua
-- A module for creating and manipulating Set data structures in Lua.
-- Sets are implemented using Lua tables, where elements are keys.
-- This provides O(1) average time complexity for add, remove, and contains operations.

Set = {}
Set.__index = Set

--- Creates a new empty set.
-- @return table A new set instance.
function Set.new()
    local newSet = {}
    -- Use a metatable to give the set object a custom type and methods.
    return setmetatable(newSet, Set)
end

--- Adds an element to the set.
-- @param self table The set instance.
-- @param element any The element to add.
function Set:add(element)
    self[element] = true
end

--- Removes an element from the set.
-- @param self table The set instance.
-- @param element any The element to remove.
function Set:remove(element)
    self[element] = nil
end

--- Checks if an element is in the set.
-- @param self table The set instance.
-- @param element any The element to check for.
-- @return boolean True if the element is in the set, false otherwise.
function Set:contains(element)
    return self[element] ~= nil
end

--- Returns the number of elements in the set.
-- This iterates over the table, so it's O(n) complexity.
-- For simple use cases, this is fine, but for performance-critical scenarios,
-- you might want to maintain a separate count variable.
-- @param self table The set instance.
-- @return number The number of elements.
function Set:size()
    local count = 0
    for _ in pairs(self) do
        count = count + 1
    end
    return count
end

--- Returns an iterator for the elements in the set.
-- @param self table The set instance.
-- @return function An iterator function.
function Set:elements()
    local i = 0
    local keys = {}
    for k in pairs(self) do
        keys[#keys + 1] = k
    end
    return function()
        i = i + 1
        return keys[i]
    end
end

--- Creates a new set that is the union of two sets.
-- @param self table The first set.
-- @param otherSet table The second set.
-- @return table The new set containing all elements from both sets.
function Set:union(otherSet)
    local newSet = Set.new()
    for k in pairs(self) do
        newSet:add(k)
    end
    for k in pairs(otherSet) do
        newSet:add(k)
    end
    return newSet
end

--- Creates a new set that is the intersection of two sets.
-- @param self table The first set.
-- @param otherSet table The second set.
-- @return table The new set containing only elements common to both sets.
function Set:intersection(otherSet)
    local newSet = Set.new()
    for k in pairs(self) do
        if otherSet:contains(k) then
            newSet:add(k)
        end
    end
    return newSet
end

--- Creates a new set that is the difference of two sets (self - otherSet).
-- @param self table The first set.
-- @param otherSet table The second set.
-- @return table The new set containing elements in the first set but not the second.
function Set:difference(otherSet)
    local newSet = Set.new()
    for k in pairs(self) do
        if not otherSet:contains(k) then
            newSet:add(k)
        end
    end
    return newSet
end

--- Checks if this set is a subset of another set.
-- @param self table The potential subset.
-- @param otherSet table The potential superset.
-- @return boolean True if the first set is a subset of the second, false otherwise.
function Set:is_subset(otherSet)
    for k in pairs(self) do
        if not otherSet:contains(k) then
            return false
        end
    end
    return true
end

function Set:serialize()
    local data = self.map(function(v)
        if v.serialize then
            return v.serialize()
        end
        return v
    end)
    return { typeid = "set", data = table.concat(data, ",") }
end

function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

function table.map(f, t)
    local r = {}
    for i, v in ipairs(t) do
        r[i] = f(v)
    end
    return r
end

function Deserialize(data)
    if (data.typeid == "stack") then
        local stack = Stack.new()
        for i, v in ipairs(data.data:split(",")) do
            stack:push(Deserialize(v))
        end
        return stack
    elseif (data.typeid == "vec3") then
        return Vec3.new(data.x, data.y, data.z)
    elseif (data.typeid == "set") then
        local set = Set.new()
        for i, v in ipairs(data.data:split(",")) do
            set:add(Deserialize(v))
        end
        return set
    end
    return data
end

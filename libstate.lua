
local function Serialize(data)
    if type(data) ~= "table" then
        return data
    end

    if type(data.serialize) == "function" then
        return data:serialize()
    end

    local new_tbl = {}
    for k, v in pairs(data) do
        new_tbl[Serialize(k)] = Serialize(v)
    end
    return new_tbl
end

function SaveState()
    local r = fs.open("resume", "w")
    r.write(shell.getRunningProgram())
    r.close()
    local f = fs.open("save", "w")
    f.write(textutils.serialize(Serialize(_G.STATE or {})))
    f.flush()
    f.close()
end

function ResetState()
    fs.delete("save")
    fs.delete("resume")
    _G.STATE = nil
end

function LoadState()
    if not fs.exists("save") then
        return
    end
    local f = fs.open("save", "r")
    _G.STATE = Deserialize(textutils.unserialize(f.readAll()))
    f.close()
end

function UseState(key, initial)
    return function()
        if _G.STATE == nil then
            _G.STATE = {}
        end
        if _G.STATE[key] == nil then
            _G.STATE[key] = initial
        end
        return _G.STATE[key]
    end, function(v)
        _G.STATE[key] = v
        SaveState()
    end
end

if fs.exists("resume") then
    local r = fs.open("resume", "r")
    local program = r.readAll()
    if program ~= shell.getRunningProgram() then
        error("Not the correct program expected " .. program .. " got " .. shell.getRunningProgram())
    end
    Resumed = true
    LoadState()
    print("Resuming after Termination")
end

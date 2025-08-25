Version = -1
function GetRepo()
    local repo = "todo"

    local indexraw = http.get(repo .. "/index.json")
    local index = textutils.unserialiseJSON(indexraw)

    local versionfile = fs.open("version", "r")
    local content = versionfile.readAll()

    if #content > 0 then
        local version = textutils.unserialiseJSON(content)
        if version.version == index.version then
            print("Version is up to date")
            Version = version.version
            return
        end
    end
    print("Version is out of date updating")
    for _, v in pairs(index.files) do
        print("Downloading " .. v)
        local file = http.get(repo .. "/" .. v)
        local f = fs.open(v, "w")
        f.write(file)
        f.close()
    end
    Version = index.version
    versionfile.write(textutils.serialiseJSON(index))
    versionfile.close()
end

GetRepo()
print([[
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│ ####### #######  #####  ####### #     # ######  ### #     # #######  #####  │
│    #    #       #     #    #    #     # #     #  #  ##    # #       #     # │
│    #    #       #          #    #     # #     #  #  # #   # #       #       │
│    #    #####    #####     #    #     # #     #  #  #  #  # #####    #####  │
│    #    #             #    #    #     # #     #  #  #   # # #             # │
│    #    #       #     #    #    #     # #     #  #  #    ## #       #     # │
│    #    #######  #####     #     #####  ######  ### #     # #######  #####  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
]])
print("Started Version: " .. Version)
print("Fuel Level: " .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit())

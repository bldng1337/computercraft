require("libmove")
require("libinventory")

for _, junk in pairs({ "cobble", "granit", "andesit", "gravel", "bluestone", "cobbled", "tuff", "rack" }) do
    ToClear:add(junk)
end

for _, worth in pairs({ "ore", "debris", ItemMatcher.newTag("forge:ores"), ItemMatcher.newTag("balm:ores") }) do
    ToVeinMine:add(worth)
end

Keep:add("bucket")

while GetPosition():manhattan() < 100 do
    Move(1, 0, 0)
    Dig(UP)
    CheckInv()
end

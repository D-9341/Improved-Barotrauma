if not SERVER then return end

Networking.Receive("reloadserverconfig", function(msg, sender)
    dofile(RealSonar.Path .. "/Lua/loadconfig.lua")
end)

Networking.Receive("getsonaritems", function(msg, sender)
    RealSonar.getSonarItems()
end)

Networking.Receive("setitemtags", function(msg, sender)
    RealSonar.setItemTags()
end)
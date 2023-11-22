if SERVER then
    Networking.Receive("reloadserverconfig", function(msg, sender)
        dofile(RealSonar.Path .. "/Lua/loadconfig.lua")
    end)
end
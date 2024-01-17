RealSonar = {}
RealSonar.Path = table.pack(...)[1]
RealSonar.sonarItems = {}
RealSonar.EnemySub = nil
RealSonar.LITE = false

-- Load config.
dofile(RealSonar.Path .. "/Lua/loadconfig.lua")

-- Shared.
dofile(RealSonar.Path .. "/Lua/anechoicsuit.lua")

-- Server-side / Singleplayer.
if (Game.IsMultiplayer and SERVER) or not Game.IsMultiplayer or RealSonar.Config.LowLatencyMode then
    dofile(RealSonar.Path .. "/Lua/functions.lua")
    dofile(RealSonar.Path .. "/Lua/sonarping.lua")
    dofile(RealSonar.Path .. "/Lua/roundstart.lua")
    dofile(RealSonar.Path .. "/Lua/servercontrol.lua")
    dofile(RealSonar.Path .. "/Lua/cortizideoverride.lua")
    dofile(RealSonar.Path .. "/Lua/networkmessages.lua")
    dofile(RealSonar.Path .. "/Lua/think.lua")
    if RealSonar.LITE == false then
        dofile(RealSonar.Path .. "/Lua/aiobjectives.lua")
    end
end

-- Client-side / Singleplayer.
if SERVER then return end
dofile(RealSonar.Path .. "/Lua/soundvolume.lua")
dofile(RealSonar.Path .. "/Lua/stopsounds.lua")
dofile(RealSonar.Path .. "/Lua/menu.lua")
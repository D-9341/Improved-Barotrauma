-- The functions in this file apply and maintain the "serversidelua" affliction on all characters.
-- This affliction allows the server to control Real Sonar using Lua without causing desync for users without it.
-- Basically, client-side Lua is no longer needed to experience Real Sonar's advanced features, anyone can jump in.

Hook.Add("character.created", "enableServerSideLua", function(createdCharacter)
    RealSonar.GiveAffliction(createdCharacter, "serversidelua", 1)
end)

Hook.Patch(
    "Barotrauma.DebugConsole",
    "ExecuteCommand",
    function(instance, ptable)
    
    local characterHealed = false
    for word in string.gmatch(ptable["command"], "[^%s]+") do
        if word == "revive" or word == "heal" then
            characterHealed = true
        end
    end
    if characterHealed then
        RealSonar.updateServerControl()
    end
end, Hook.HookMethodType.After)

if not (Game.IsMultiplayer and SERVER) or RealSonar.Config.LowLatencyMode then return end
Hook.Patch(
    "Barotrauma.DebugConsole",
    "ExecuteClientCommand",
    function(instance, ptable)
    
    local characterHealed = false
    for word in string.gmatch(ptable["command"], "[^%s]+") do
        if word == "revive" or word == "heal" then
            characterHealed = true
        end
    end
    if characterHealed then
        RealSonar.updateServerControl()
    end
end, Hook.HookMethodType.After)
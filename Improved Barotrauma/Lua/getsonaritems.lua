
Hook.Add("roundStart", "getSonarItems", function()
    for item in Item.RepairableItems do
        local id = item.Prefab.Identifier.Value
        if id == "navterminal" or id == "sonarmonitor" then -- Add shuttlenavterminal too when the rework is done.
            table.insert(RealSonar.sonarItems, item)
        end
    end
end)

-- Ensures certain features like AI Objectives still work after reloading Lua mid-game.
Hook.Add("loaded", "getSonarItems", function()
    for item in Item.RepairableItems do
        local id = item.Prefab.Identifier.Value
        if id == "navterminal" or id == "sonarmonitor" then -- Add shuttlenavterminal too when the rework is done.
            table.insert(RealSonar.sonarItems, item)
        end
    end
end)


Hook.Add("roundStart", "getSonarItems", function()
    RealSonar.getSonarItems()
    RealSonar.setSonarRanges()
    RealSonar.getEnemySub()
    RealSonar.setItemTags()
end)

-- Ensures certain features like AI Objectives and enemy sonar still work after reloading Lua mid-game.
Hook.Add("loaded", "getSonarItems", function()
    RealSonar.getSonarItems()
    RealSonar.setSonarRanges()
    RealSonar.getEnemySub()
    RealSonar.setItemTags()
end)

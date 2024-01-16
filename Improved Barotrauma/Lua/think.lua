local enemySonarCooldown = 20 * 60
local updateAfflictionCooldown = 2 * 60

Hook.Add("think", "think", function()
    if Game.Paused or not Game.RoundStarted then return end

    if RealSonar.EnemySub then
        if enemySonarCooldown <= 0 then
            enemySonarCooldown = RealSonar.updateEnemySonarMode() * 60
        end
        enemySonarCooldown = enemySonarCooldown - 1
    end

    if updateAfflictionCooldown <= 0 then
        updateAfflictionCooldown = RealSonar.updateBrainHemorrhage() * 60
    end
    updateAfflictionCooldown = updateAfflictionCooldown - 1
end)

Hook.Add("sonarPingNav", "sonarPingNav", function(effect, deltaTime, item, targets, worldPosition)
    local distance
    local amount
    local sonar
    local damageMultiplier
    for _, character in pairs(Character.CharacterList) do
        distance = RealSonar.distanceBetween(item.worldPosition, character.worldPosition)
        sonar = item.GetComponentString("Sonar")
        if distance < sonar.Range then
            amount = (1 - distance / sonar.Range) * 100
            -- Air.
            if not character.InWater or not RealSonar.pathToBreach(character) then
                if character.isPlayer then
                    RealSonar.airSounds(character, amount)
                end
            -- Water.
            elseif not RealSonar.hasSonarResistance(character) and RealSonar.pathToBreach(character) then
                RealSonar.GiveAffliction(character, "activesonar", amount)
                if character.isPlayer then
                    RealSonar.waterSounds(character, amount)
                end
                if character.isHuman then
                    RealSonar.GiveAffliction(character, "sonarimpact", amount)
                end
                if character.isBot and character.IsOnPlayerTeam and not character.IsUnconscious then
                    character.Speak(TextManager.Get("dialogturnoffsonar").Value, nil, 0.5, "dialogturnoffsonar", 5)
                end
            -- Suit.
            elseif RealSonar.hasSonarResistance(character) and RealSonar.pathToBreach(character) then
                damageMultiplier = RealSonar.getSonarResistance(character, "activesonar")
                RealSonar.GiveAffliction(character, "activesonar", amount * damageMultiplier)
                if character.isPlayer then
                    RealSonar.suitSounds(character, amount)
                end
            end
        end
    end
    -- Cancel the rest of the Status Effect.
    return true
end)

Hook.Add("sonarPingNavDirectional", "sonarPingNavDirectional", function(effect, deltaTime, item, targets, worldPosition)
    local distance
    local amount
    local sonar
    local damageMultiplier
    for _, character in pairs(Character.CharacterList) do
        distance = RealSonar.distanceBetween(item.worldPosition, character.worldPosition)
        sonar = item.GetComponentString("Sonar")
        if distance < sonar.Range then
            amount = (1 - distance / sonar.Range) * 100
            -- Air.
            if not character.InWater or not RealSonar.pathToBreach(character) then
                if character.isPlayer then
                    RealSonar.airSoundsDirectional(character, amount)
                end
            -- Water.
            elseif not RealSonar.hasSonarResistance(character) and RealSonar.pathToBreach(character) then
                if RealSonar.inDirectionalSector(character, item) then
                    RealSonar.GiveAffliction(character, "activesonar", amount * 1.5)
                    if character.isHuman then
                        RealSonar.GiveAffliction(character, "sonarimpact", amount * 1.5)
                    end
                    if character.isPlayer then
                        RealSonar.waterSounds(character, amount * 2)
                    end
                else
                    RealSonar.GiveAffliction(character, "activesonar", amount * 0.6)
                    if character.isPlayer then
                        RealSonar.waterSoundsDirectional(character, amount)
                    end
                end
            -- Suit.
            elseif RealSonar.hasSonarResistance(character) and RealSonar.pathToBreach(character) then
                damageMultiplier = RealSonar.getSonarResistance(character, "activesonar")
                if RealSonar.inDirectionalSector(character, item) then
                    RealSonar.GiveAffliction(character, "activesonar", (amount * 1.5) * damageMultiplier)
                    if character.isPlayer then
                        RealSonar.suitSounds(character, amount * 2)
                    end
                else
                    RealSonar.GiveAffliction(character, "activesonar", (amount * 0.6) * damageMultiplier)
                    if character.isPlayer then
                        RealSonar.suitSoundsDirectional(character, amount)
                    end
                end
            end
        end
    end
    -- Cancel the rest of the Status Effect.
    return true
end)

Hook.Add("sonarPingMonitor", "sonarPingMonitor", function(effect, deltaTime, item, targets, worldPosition)
    local distance
    local amount
    local sonar
    local damageMultiplier
    for _, character in pairs(Character.CharacterList) do
        distance = RealSonar.distanceBetween(item.worldPosition, character.worldPosition)
        sonar = item.GetComponentString("Sonar")
        if distance < sonar.Range then
            amount = (1 - distance / sonar.Range) * 100
            -- Air.
            if not character.InWater or not RealSonar.pathToBreach(character) then
                if character.isPlayer then
                    RealSonar.airSounds(character, amount)
                end
            -- Water.
            elseif not RealSonar.hasSonarResistance(character) and RealSonar.pathToBreach(character) then
                RealSonar.GiveAffliction(character, "activesonarbeacon", amount)
                if character.isPlayer then
                    RealSonar.waterSounds(character, amount)
                end
                if character.isHuman then
                    RealSonar.GiveAffliction(character, "sonarimpactbeacon", amount)
                end
                if character.isBot and character.IsOnPlayerTeam and not character.IsUnconscious then
                    character.Speak(TextManager.Get("dialogturnoffsonar").Value, nil, 0.5, "dialogturnoffsonar", 5)
                end
            -- Suit.
            elseif RealSonar.hasSonarResistance(character) and RealSonar.pathToBreach(character) then
                damageMultiplier = RealSonar.getSonarResistance(character, "activesonarbeacon")
                RealSonar.GiveAffliction(character, "activesonarbeacon", amount * damageMultiplier)
                if character.isPlayer then
                    RealSonar.suitSounds(character, amount)
                end
            end
        end
    end
    -- Cancel the rest of the Status Effect.
    return true
end)

Hook.Add("sonarPingMonitorDirectional", "sonarPingMonitorDirectional", function(effect, deltaTime, item, targets, worldPosition)
    local distance
    local amount
    local sonar
    local damageMultiplier
    for _, character in pairs(Character.CharacterList) do
        distance = RealSonar.distanceBetween(item.worldPosition, character.worldPosition)
        sonar = item.GetComponentString("Sonar")
        if distance < sonar.Range then
            amount = (1 - distance / sonar.Range) * 100
            -- Air.
            if not character.InWater or not RealSonar.pathToBreach(character) then
                if character.isPlayer then
                    RealSonar.airSoundsDirectional(character, amount)
                end
            -- Water.
            elseif not RealSonar.hasSonarResistance(character) and RealSonar.pathToBreach(character) then
                if RealSonar.inDirectionalSector(character, item) then
                    RealSonar.GiveAffliction(character, "activesonarbeacon", amount * 1.5)
                    if character.isHuman then
                        RealSonar.GiveAffliction(character, "sonarimpactbeacon", amount * 1.5)
                    end
                    if character.isPlayer then
                        RealSonar.waterSounds(character, amount * 2)
                    end
                else
                    RealSonar.GiveAffliction(character, "activesonarbeacon", amount * 0.6)
                    if character.isPlayer then
                        RealSonar.waterSoundsDirectional(character, amount)
                    end
                end
            -- Suit.
            elseif RealSonar.hasSonarResistance(character) and RealSonar.pathToBreach(character) then
                damageMultiplier = RealSonar.getSonarResistance(character, "activesonarbeacon")
                if RealSonar.inDirectionalSector(character, item) then
                    RealSonar.GiveAffliction(character, "activesonarbeacon", (amount * 1.5) * damageMultiplier)
                    if character.isPlayer then
                        RealSonar.suitSounds(character, amount * 2)
                    end
                else
                    RealSonar.GiveAffliction(character, "activesonarbeacon", (amount * 0.6) * damageMultiplier)
                    if character.isPlayer then
                        RealSonar.suitSoundsDirectional(character, amount)
                    end
                end
            end
        end
    end
    -- Cancel the rest of the Status Effect.
    return true
end)

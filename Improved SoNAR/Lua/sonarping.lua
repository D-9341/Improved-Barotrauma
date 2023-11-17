Hook.Add("sonarPing", "sonarPing", function(effect, deltaTime, item, targets, worldPosition)
    local distance
    local amount
    local terminal_type
    local sonarResistanceData
    local damageMultiplier
    local muffleSonar
    local sonar = item.GetComponentString("Sonar")
    local terminal_id = item.Prefab.Identifier.Value

    local waterSounds
    local airSounds
    local suitSounds

    -- Select correct sound-playing function.
    if terminal_id == "navterminal" or terminal_id == "sonarmonitor" then
        airSounds = RealSonar.airSounds
        waterSounds = RealSonar.waterSounds
        suitSounds = RealSonar.suitSounds
    elseif terminal_id == "shuttlenavterminal" then
        airSounds = RealSonar.airSoundsShuttle
        waterSounds = RealSonar.waterSoundsShuttle
        suitSounds = RealSonar.suitSoundsShuttle
    end

    terminal_type = RealSonar.getTerminalTypeFromID(terminal_id)
    
    for _, character in pairs(Character.CharacterList) do
        distance = RealSonar.distanceBetween(item.worldPosition, character.worldPosition)
        if distance < sonar.Range and not character.isDead then
            
            amount = (1 - distance / sonar.Range) * 100
            
            -- Air sounds.
            if (not character.InWater or not RealSonar.isEnabledForTerminal(terminal_id) or not RealSonar.pathToBreach(character)) and character.isPlayer then
                airSounds(character, amount)

            elseif RealSonar.isEnabledForTerminal(terminal_id) and RealSonar.pathToBreach(character) then
                sonarResistanceData = RealSonar.getSonarResistanceData(character)
                damageMultiplier = sonarResistanceData[1]
                muffleSonar = sonarResistanceData[2]

                -- Damage.
                RealSonar.GiveAffliction(character, string.format("activesonar%slua", terminal_type), (amount * damageMultiplier) * RealSonar.Config.SonarDamage)

                -- Stun & slow.
                if character.isHuman and not muffleSonar then
                    RealSonar.GiveAffliction(character, string.format("sonarshakestun%s", terminal_type), (amount * damageMultiplier) * RealSonar.Config.ImpactVisuals)
                    RealSonar.SetAffliction(character, string.format("sonarslow%s", terminal_type), (amount * damageMultiplier) * RealSonar.Config.SonarSlow)
                end

                -- Water sounds & impact visuals.
                if not muffleSonar and character.isPlayer then
                    RealSonar.GiveAffliction(character, string.format("sonarvisuals%s", terminal_type), (amount * damageMultiplier) * RealSonar.Config.ImpactVisuals)
                    waterSounds(character, amount * damageMultiplier)
                
                -- Suit sounds.
                elseif character.isPlayer then
                    suitSounds(character, amount)
                end

                -- Bot messages.
                if terminal_id ~= "sonarmonitor" and character.isBot and character.IsOnPlayerTeam and not character.IsUnconscious then
                    character.Speak(TextManager.Get("dialogturnoffsonar").Value, nil, 0.5, "dialogturnoffsonar", 5)
                end
            end
        end
    end

    -- Cancel the rest of the Status Effect.
    return true
end)


Hook.Add("sonarPingDirectional", "sonarPingDirectional", function(effect, deltaTime, item, targets, worldPosition)
    local distance
    local amount
    local terminal_type
    local sonarResistanceData
    local damageMultiplier
    local muffleSonar
    local sonar = item.GetComponentString("Sonar")
    local terminal_id = item.Prefab.Identifier.Value

    local soundRangeMultiplier = 2.0
    local inConeDamageMultiplier = 1.7
    local outConeDamageMultiplier = 0.6

    local airSoundsDirectional
    local waterSoundsDirectional
    local suitSoundsDirectional
    local waterSounds
    local suitSounds

    -- Select correct sound-playing function.
    if terminal_id == "navterminal" or terminal_id == "sonarmonitor" then
        airSoundsDirectional = RealSonar.airSoundsDirectional
        waterSoundsDirectional = RealSonar.waterSoundsDirectional
        suitSoundsDirectional = RealSonar.suitSoundsDirectional
        waterSounds = RealSonar.waterSounds
        suitSounds = RealSonar.suitSounds
    elseif terminal_id == "shuttlenavterminal" then
        airSoundsDirectional = RealSonar.airSoundsShuttleDirectional
        waterSoundsDirectional = RealSonar.waterSoundsShuttleDirectional
        suitSoundsDirectional = RealSonar.suitSoundsShuttleDirectional
        waterSounds = RealSonar.waterSoundsShuttle
        suitSounds = RealSonar.suitSoundsShuttle
    end

    terminal_type = RealSonar.getTerminalTypeFromID(terminal_id)

    for _, character in pairs(Character.CharacterList) do
        distance = RealSonar.distanceBetween(item.worldPosition, character.worldPosition)
        if distance < sonar.Range and not character.isDead then

            amount = (1 - distance / sonar.Range) * 100

            -- Air sounds.
            if (not character.InWater or not RealSonar.isEnabledForTerminal(terminal_id) or not RealSonar.pathToBreach(character)) and character.isPlayer then
                airSoundsDirectional(character, amount)

            elseif RealSonar.isEnabledForTerminal(terminal_id) and RealSonar.pathToBreach(character) then
                sonarResistanceData = RealSonar.getSonarResistanceData(character)
                damageMultiplier = sonarResistanceData[1]
                muffleSonar = sonarResistanceData[2]
                
                -- Being aimed at.
                if RealSonar.inDirectionalSector(character, item) then
                    -- Damage.
                    RealSonar.GiveAffliction(character, string.format("activesonar%slua", terminal_type), ((amount * damageMultiplier) * inConeDamageMultiplier) * RealSonar.Config.SonarDamage)
                    
                    -- Stun & slow.
                    if character.isHuman and not muffleSonar then
                        RealSonar.GiveAffliction(character, string.format("sonarshakestun%s", terminal_type), ((amount * damageMultiplier) * inConeDamageMultiplier) * RealSonar.Config.ImpactVisuals)
                        RealSonar.SetAffliction(character, string.format("sonarslow%s", terminal_type), ((amount * damageMultiplier) * inConeDamageMultiplier) * RealSonar.Config.SonarSlow)
                    end

                    -- Water sounds & impact visuals.
                    if not muffleSonar and character.isPlayer then
                        RealSonar.GiveAffliction(character, string.format("sonarvisuals%s", terminal_type), ((amount * damageMultiplier) * inConeDamageMultiplier) * RealSonar.Config.ImpactVisuals)
                        waterSounds(character, (amount * damageMultiplier) * soundRangeMultiplier)
                    
                    -- Suit sounds.
                    elseif character.isPlayer then
                        suitSounds(character, (amount * damageMultiplier) * soundRangeMultiplier)
                    end
                    
                    -- Bot messages.
                    if terminal_id ~= "sonarmonitor" and character.isBot and character.IsOnPlayerTeam and not character.IsUnconscious then
                        character.Speak(TextManager.Get("dialogturnoffsonar").Value, nil, 0.5, "dialogturnoffsonar", 5)
                    end
                -- Not being aimed at.
                else
                    -- Damage.
                    RealSonar.GiveAffliction(character, string.format("activesonar%slua", terminal_type), ((amount * damageMultiplier) * outConeDamageMultiplier) * RealSonar.Config.SonarDamage)

                    -- Water sounds.
                    if not muffleSonar and character.isPlayer then
                        waterSoundsDirectional(character, amount)

                    -- Suit sounds.
                    elseif character.isPlayer then
                        suitSoundsDirectional(character, amount)
                    end
                end
            end
        end
    end

    -- Cancel the rest of the Status Effect.
    return true
end)
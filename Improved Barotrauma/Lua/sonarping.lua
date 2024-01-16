-- It would technically be faster to patch the Barotrauma.Items.Components.Sonar.Use method.
-- But doing so would not allow me to stop the default ping sound from playing.
Hook.Patch(
    "Barotrauma.Item", "Use", function(instance, ptable)
    if not RealSonar.Config.CustomSonar then
        return
    end
    local instance_sonar = instance.GetComponentString("Sonar")
    for terminal in RealSonar.sonarItems do
        if terminal.GetComponentString("Sonar") == instance_sonar then
            if instance_sonar.UseDirectionalPing then
                Hook.Call("sonarPingDirectional", nil, nil, terminal)
            else
                Hook.Call("sonarPing", nil, nil, terminal)
            end
            -- Prevent default ping sound from playing.
            ptable.PreventExecution = true
        end
    end
end, Hook.HookMethodType.Before)

Hook.Add("sonarPing", "sonarPing", function(effect, deltaTime, item, targets, worldPosition)
    local terminal_id = item.Prefab.Identifier.Value
    local sonar = item.GetComponentString("Sonar")

    -- deltaTime being passed in means that the hook was called from XML
    if RealSonar.Config.CustomSonar and deltaTime then

        -- If the terminal is registered cancel the XML status effect.
        if RealSonar.Config.SonarTerminals[terminal_id] then
            return true

        -- Otherwise, add the terminal to the config.
        else
            RealSonar.Config.SonarTerminals[terminal_id] = {}
            RealSonar.Config.SonarTerminals[terminal_id]["damage"] = "high"
            RealSonar.Config.SonarTerminals[terminal_id]["sounds"] = "default"
            RealSonar.Config.SonarTerminals[terminal_id]["range"] = sonar.Range
            table.insert(RealSonar.sonarItems, item)
            print("Real Sonar: Automatically added '", terminal_id, "' to config with default values.")
        end
    end

    local distance
    local amount
    local terminal_type
    local sonarResistanceData
    local damageMultiplier
    local muffleSonar

    -- Select correct sound-playing function.
    local soundPreset = "default"
    if RealSonar.Config.SonarTerminals[terminal_id] then
        soundPreset = RealSonar.Config.SonarTerminals[terminal_id]["sounds"]
    end
    local airSounds = RealSonar.airSounds
    local waterSounds = RealSonar.waterSounds
    local suitSounds = RealSonar.suitSounds
    if soundPreset == "shuttle" then
        airSounds = RealSonar.airSoundsShuttle
        waterSounds = RealSonar.waterSoundsShuttle
        suitSounds = RealSonar.suitSoundsShuttle
    end


    terminal_type = RealSonar.getTerminalType(terminal_id)
    
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
    local terminal_id = item.Prefab.Identifier.Value
    local sonar = item.GetComponentString("Sonar")

    -- deltaTime being passed in means that the hook was called from XML
    if RealSonar.Config.CustomSonar and deltaTime then
        
        -- If the terminal is registered cancel the XML status effect.
        if RealSonar.Config.SonarTerminals[terminal_id] then
            return true

        -- Otherwise, add the terminal to the config.
        else
            RealSonar.Config.SonarTerminals[terminal_id] = {}
            RealSonar.Config.SonarTerminals[terminal_id]["damage"] = "high"
            RealSonar.Config.SonarTerminals[terminal_id]["sounds"] = "default"
            RealSonar.Config.SonarTerminals[terminal_id]["range"] = sonar.Range
            table.insert(RealSonar.sonarItems, item)
            print("Real Sonar: Automatically added '", terminal_id, "' to config with default values.")
        end
    end

    local distance
    local amount
    local terminal_type
    local sonarResistanceData
    local damageMultiplier
    local muffleSonar

    local soundRangeMultiplier = 2.0
    local inConeDamageMultiplier = 1.5
    local outConeDamageMultiplier = 0.6

    -- Select correct sound-playing function.
    local soundPreset = "default"
    if RealSonar.Config.SonarTerminals[terminal_id] then
        soundPreset = RealSonar.Config.SonarTerminals[terminal_id]["sounds"]
    end
    local airSoundsDirectional = RealSonar.airSoundsDirectional
    local waterSoundsDirectional = RealSonar.waterSoundsDirectional
    local suitSoundsDirectional = RealSonar.suitSoundsDirectional
    local waterSounds = RealSonar.waterSounds
    local suitSounds = RealSonar.suitSounds
    if soundPreset == "shuttle" then
        airSoundsDirectional = RealSonar.airSoundsShuttleDirectional
        waterSoundsDirectional = RealSonar.waterSoundsShuttleDirectional
        suitSoundsDirectional = RealSonar.suitSoundsShuttleDirectional
        waterSounds = RealSonar.waterSoundsShuttle
        suitSounds = RealSonar.suitSoundsShuttle
    end

    terminal_type = RealSonar.getTerminalType(terminal_id)

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
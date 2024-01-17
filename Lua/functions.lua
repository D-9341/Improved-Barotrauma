LuaUserData.RegisterType("Barotrauma.DamageModifier")
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Items.Components.Sonar"], "pingDirection")

-- Returns true if there is a valid path from a hull breach to the character.
function RealSonar.pathToBreach(character)

    -- Creature damage.
    if not RealSonar.Config.CreatureDamage and not character.isHuman then
        return false
    end

    -- Player damage.
    if not RealSonar.Config.PlayerDamage and character.isPlayer then
        return false
    end

    -- Bot damage.
    if not RealSonar.Config.BotDamage and character.isBot then
        return false
    end

    -- Returns false for ignored characters.
    for identifier in RealSonar.Config.IgnoredCharacters do
        if identifier == character.Prefab.Identifier.Value then
            return false
        end
    end

    -- Returns true for characters outside.
    if not character.AnimController.currentHull then
        return true
    end

    -- Creature hull detection.
    if not RealSonar.Config.CreatureHullDetection and not character.isHuman and character.InWater then
        return true
    end

    -- Human hull detection.
    if not RealSonar.Config.HumanHullDetection and character.isHuman and character.InWater then
        return true
    end
    
    -- This code looks absolutely atrocious. It's so bad that I'm afraid to go near it to refactor it.
    local hulls = character.AnimController.currentHull.GetConnectedHulls(true, 100, true)
    local hullCount = 0
    local waterFilledHulls = 0
    for hull in hulls do
        hullCount = hullCount + 1
        if hull.WaterPercentage >= 50 then
            waterFilledHulls = waterFilledHulls + 1
        end
        for gap in hull.ConnectedGaps do
            -- If breach is external, more than 40% open, and water level is above the lower boundary of the gap .
            if gap.IsRoomToRoom == false and gap.open >= 0.4 and hull.Surface + hull.WaveY[#hull.WaveY - 1] > gap.rect.Y - gap.Size then
                -- If character position is below the gap.
                if character.Position.Y < gap.rect.Y - gap.Size then
                    -- If the majority of the connected hulls are filled with water.
                    if waterFilledHulls >= hullCount - 1 then
                        return true
                    end
                else
                    return true
                end
            end
        end
    end
    return false
end

-- Returns true if there's a mild external hull breach in the character's structure.
function RealSonar.hullBreached(character)
    if not character.AnimController.currentHull then
        return true
    end
    local hulls = character.AnimController.currentHull.GetConnectedHulls(true, 100, false)
    for hull in hulls do
        for gap in hull.ConnectedGaps do
            if gap.IsRoomToRoom == false and gap.open >= 0.4 then
                return true
            end
        end
    end
    return false
end

-- Returns the distance between two points in 2D space.
function RealSonar.distanceBetween(point1, point2)
    local xd = point1.X - point2.X
    local yd = point1.Y - point2.Y
    return math.sqrt(xd*xd + yd*yd)
end

-- Returns true if the character is dangerously close to any active sonar source.
-- Ideally this checks if the gap is in range instead of the character, but I can't find a way to pass it in.
function RealSonar.characterInSonarRange(character)
    local inSonar = false
    local sonar
    for item in RealSonar.sonarItems do
        sonar = item.GetComponentString("Sonar")
        if tostring(sonar.currentMode) == "Active" and sonar.Voltage > sonar.minVoltage and RealSonar.distanceBetween(item.worldPosition, character.worldPosition) <= sonar.Range * 0.75 then
            if sonar.UseDirectionalPing then
                if RealSonar.inDirectionalSector(character, item) then
                    inSonar = true
                    break
                end
            else
                inSonar = true
                break
            end
        end
    end
    return inSonar
end

-- Returns true if the charcter is inside the direction ping sector.
function RealSonar.inDirectionalSector(character, item)
    local sonar = item.GetComponentString("Sonar")

    local px, py = character.worldPosition.X, character.worldPosition.Y
    local cx, cy = item.Submarine.WorldPosition.X, item.Submarine.WorldPosition.Y
    local r = sonar.Range
    local theta = math.atan2(-sonar.pingDirection.Y, sonar.pingDirection.X) * 180 / math.pi

    local dx = px - cx
    local dy = py - cy
    local angle = math.atan2(dy, dx) * 180 / math.pi
    
    if angle < 0 then
        angle = angle + 360
    end

    local angle_diff = math.abs(angle - theta)
    if angle_diff <= 15 or angle_diff >= 345 then
        local dist = math.sqrt((px - cx)^2 + (py - cy)^2)
        if dist <= r then
            return true
        end
    end

    return false
end

function RealSonar.getSonarResistanceData(character)
    local resistanceData = {}
    local damageModifier = 1
    local muffleSonar = false

    if not character or not character.Inventory then
        table.insert(resistanceData, damageModifier)
        table.insert(resistanceData, muffleSonar)
        return resistanceData
    end

    local outerClothes = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
    local innerClothes = character.Inventory.GetItemInLimbSlot(InvSlotType.InnerClothes)
    local head = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)
    local equippedClothing = {}
    if outerClothes then table.insert(equippedClothing, outerClothes) end
    if innerClothes then table.insert(equippedClothing, innerClothes) end
    if head then table.insert(equippedClothing, head) end

    local identifier
    local wearable
    local configOverride = false
    for clothing in equippedClothing do
        identifier = clothing.Prefab.Identifier.Value
        wearable = clothing.GetComponentString("Wearable")

        -- Checking config.
        for id, data in pairs(RealSonar.Config.WearableProtections) do
            if id == identifier then
                damageModifier = damageModifier - data["damageMultiplier"]
                configOverride = true
                if data["anechoic"] == true then
                    muffleSonar = true
                end
                break
            end
        end

        -- Checking items.
        if not configOverride then
            if clothing.HasTag("anechoic") then
                muffleSonar = true
            end
            for modifier in wearable.DamageModifiers do
                if modifier.AfflictionTypes == "activesonar" then
                    damageModifier = damageModifier - (1 - modifier.DamageMultiplier)
                end
            end
        end
        configOverride = false
    end

    -- Constraints. Having 2 be the max allows for negative protection values on diving suits up to -1.0
    if damageModifier < 0 then
        damageModifier = 0
    elseif damageModifier > 2 then
        damageModifier = 2
    end
    
    table.insert(resistanceData, damageModifier)
    table.insert(resistanceData, muffleSonar)
    return resistanceData
end

function RealSonar.getTerminalFromSub(sub)
    for terminal in RealSonar.sonarItems do
        if terminal.Submarine == sub then
            return terminal
        end
    end
end

function RealSonar.isEnabledForTerminal(terminal_id)
    if terminal_id == "navterminal" then
        if RealSonar.Config.SubmarineSonar then
            return true
        else
            return false
        end

    elseif terminal_id == "sonarmonitor" then
        if RealSonar.Config.BeaconSonar then
            return true
        else
            return false
        end

    elseif terminal_id =="shuttlenavterminal" then
        if RealSonar.Config.ShuttleSonar then
            return true
        else
            return false
        end
    elseif RealSonar.Config.SonarTerminals[terminal_id] then
        if RealSonar.Config.CustomSonar then
            return true
        else
            return false
        end
    -- The default return value is true because all terminals should be enabled by default.
    else
        return true
    end
end

function RealSonar.getSonarItems()
    RealSonar.sonarItems = {}
    for item in Item.RepairableItems do
        local item_id = item.Prefab.Identifier.Value
        
        for terminal_id in pairs(RealSonar.Config.SonarTerminals) do
            if item_id == terminal_id then
                table.insert(RealSonar.sonarItems, item)
            end
        end
    end
end

function RealSonar.getCaptain(sub)
    for _, character in pairs(Character.CharacterList) do
        if character.isHuman and character.Submarine == sub and character.IsCaptain then
            return character
        end
    end
end

function RealSonar.getVFXPresetString()
    if RealSonar.Config.VFXPreset == 2 then
        return ""
    elseif RealSonar.Config.VFXPreset == 1 then
        return "lowfx"
    else
        return "nofx"
    end
end

-- General reminder: It might be worth globally changing the naming convention of "", "shuttle", and "beacon" to match "high", "medium", "low"
function RealSonar.getTerminalType(terminal_id)
    local damagePreset = "high"

    if RealSonar.Config.SonarTerminals[terminal_id] then
        damagePreset = RealSonar.Config.SonarTerminals[terminal_id]["damage"]
    end

    local terminal_type = ""
    if damagePreset == "medium" then
        terminal_type = "shuttle"
    elseif damagePreset == "low" then
        terminal_type = "beacon"
    end
    return terminal_type
end

function RealSonar.getEnemySub()
    RealSonar.EnemySub = nil
    if Submarine.MainSubs[2] then
        local sub = Submarine.MainSubs[2]
        RealSonar.EnemySub = {}
        RealSonar.EnemySub.terminal = RealSonar.getTerminalFromSub(sub)
        RealSonar.EnemySub.sonar = RealSonar.EnemySub.terminal.GetComponentString("Sonar")
        RealSonar.EnemySub.captain = RealSonar.getCaptain(sub)
    end
end

function RealSonar.updateEnemySonarMode()
    local terminal = RealSonar.EnemySub.terminal
    local sonar = RealSonar.EnemySub.sonar
    local captain = RealSonar.EnemySub.captain
    if tostring(sonar.currentMode) == "Passive" and captain and not captain.IsUnconscious and not captain.isDead and RealSonar.distanceBetween(captain.WorldPosition, terminal.WorldPosition) < 700 and not RealSonar.hullBreached(captain) then
        sonar.currentMode = 0
        if Game.IsMultiplayer then
            terminal.CreateServerEvent(Components.Sonar, sonar)
        end
        return math.random(1,3)
    elseif tostring(sonar.currentMode) == "Active" and captain and not captain.IsUnconscious and not captain.isDead then
        sonar.currentMode = 1
        if Game.IsMultiplayer then
            terminal.CreateServerEvent(Components.Sonar, sonar)
        end
    end
    return math.random(6,12)
end

function RealSonar.setSonarRanges()
    if Game.IsMultiplayer then return end
    local defaultRange = 12000
    local terminal_id
    local sonar
    for terminal in RealSonar.sonarItems do
        terminal_id = terminal.Prefab.Identifier.Value

        if RealSonar.Config.SonarTerminals[terminal_id] then
            defaultRange = RealSonar.Config.SonarTerminals[terminal_id]["range"]
        end
        
        sonar = terminal.GetComponentString("Sonar")
        sonar.Range = defaultRange * RealSonar.Config.SonarRange
        --if Game.IsMultiplayer then terminal.CreateServerEvent(Components.Sonar, sonar) end
    end
end

-- This function adds the "anechoic" tag to specified items in the config file.
-- Allowing bots to wear these items while doing repairs with the sonar on.
function RealSonar.setItemTags()
    local property
    for item in Item.ItemList do
        for id, data in pairs(RealSonar.Config.WearableProtections) do
            if item.Prefab.Identifier.Value == id and data["anechoic"] then
                item.AddTag("anechoic")
                if Game.IsMultiplayer then
                    property = item.SerializableProperties[Identifier("Tags")]
                    Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(property, item))
                end
            end
        end
    end
end

-- This function will re-apply the "serversidelua" affliction if the player has manually removed it with console commands.
function RealSonar.updateServerControl()
    local affliction
    for _, character in pairs(Character.CharacterList) do
        affliction = character.CharacterHealth.GetAffliction("serversidelua", false)
        if not affliction then
            RealSonar.SetAffliction(character, "serversidelua", 1)
        end
    end
end

function RealSonar.updateBrainHemorrhage()
    local brainHemorrhages
    local fx_preset = RealSonar.getVFXPresetString()
    for _, character in pairs(Character.CharacterList) do
        if character.isHuman and not character.isDead then
            brainHemorrhages = {}
            for affliction in character.CharacterHealth.GetAllAfflictions() do
                if affliction.Prefab.Identifier.Value == "brainhemorrhage" or affliction.Prefab.Identifier.Value == "brainhemorrhagelowfx" or affliction.Prefab.Identifier == "brainhemorrhagenofx" then
                    table.insert(brainHemorrhages, affliction)
                end
            end
            for _, brainHemorrhage in pairs(brainHemorrhages) do
                if brainHemorrhage.Prefab.Identifier.Value ~= string.format("brainhemorrhage%s", fx_preset) then
                    RealSonar.GiveAfflictionHead(character, string.format("brainhemorrhage%s", fx_preset), brainHemorrhage.Strength)
                    brainHemorrhage.Strength = 0
                end
            end
        end
    end
    return 2
end

function RealSonar.GiveAffliction(character, identifier, strength)
    local prefab = AfflictionPrefab.Prefabs[identifier]
    local affliction = prefab.Instantiate(strength)
    character.CharacterHealth.ApplyAffliction(character.AnimController.GetLimb(LimbType.Torso), affliction, true)
end

function RealSonar.SetAffliction(character, identifier, strength)
    local prefab = AfflictionPrefab.Prefabs[identifier]
    local affliction = prefab.Instantiate(strength)
    character.CharacterHealth.ApplyAffliction(character.AnimController.GetLimb(LimbType.Torso), affliction, false)
end

function RealSonar.GiveAfflictionHead(character, identifier, strength)
    local prefab = AfflictionPrefab.Prefabs[identifier]
    local affliction = prefab.Instantiate(strength)
    character.CharacterHealth.ApplyAffliction(character.AnimController.GetLimb(LimbType.Head), affliction, true)
end

-- Nav terminal sounds.
function RealSonar.airSounds(character, strength)
    if strength > 95 then
        RealSonar.GiveAffliction(character, "sonarPingAirClose", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingAirMedium", 1)
    else
        RealSonar.GiveAffliction(character, "sonarPingAirFar", 1)
    end
end
function RealSonar.airSoundsDirectional(character, strength)
    if strength > 95 then
        RealSonar.GiveAffliction(character, "sonarPingAirCloseDirectional", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingAirMediumDirectional", 1)
    else
        RealSonar.GiveAffliction(character, "sonarPingAirFarDirectional", 1)
    end
end

function RealSonar.waterSounds(character, strength)
    if strength > 75 then
        RealSonar.GiveAffliction(character, "sonarPingWaterVeryClose", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingWaterClose", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingWaterMedium", 1)
    else
        RealSonar.GiveAffliction(character, "SonarPingWaterFar", 1)
    end
end
function RealSonar.waterSoundsDirectional(character, strength)
    if strength > 75 then
        RealSonar.GiveAffliction(character, "sonarPingWaterVeryCloseDirectional", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingWaterCloseDirectional", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingWaterMediumDirectional", 1)
    else
        RealSonar.GiveAffliction(character, "SonarPingWaterFarDirectional", 1)
    end
end

function RealSonar.suitSounds(character, strength)
    if strength > 75 then
        RealSonar.GiveAffliction(character, "sonarPingSuitVeryClose", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingSuitClose", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingSuitMedium", 1)
    else
        RealSonar.GiveAffliction(character, "SonarPingSuitFar", 1)
    end
end
function RealSonar.suitSoundsDirectional(character, strength)
    if strength > 75 then
        RealSonar.GiveAffliction(character, "sonarPingSuitVeryCloseDirectional", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingSuitCloseDirectional", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingSuitMediumDirectional", 1)
    else
        RealSonar.GiveAffliction(character, "SonarPingSuitFarDirectional", 1)
    end
end


-- Shuttle sounds
function RealSonar.airSoundsShuttle(character, strength)
    if strength > 95 then
        RealSonar.GiveAffliction(character, "sonarPingAirCloseShuttle", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingAirMediumShuttle", 1)
    else
        RealSonar.GiveAffliction(character, "sonarPingAirFarShuttle", 1)
    end
end
function RealSonar.airSoundsShuttleDirectional(character, strength)
    if strength > 95 then
        RealSonar.GiveAffliction(character, "sonarPingAirCloseShuttleDirectional", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingAirMediumShuttleDirectional", 1)
    else
        RealSonar.GiveAffliction(character, "sonarPingAirFarShuttleDirectional", 1)
    end
end

function RealSonar.waterSoundsShuttle(character, strength)
    if strength > 75 then
        RealSonar.GiveAffliction(character, "sonarPingWaterVeryCloseShuttle", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingWaterCloseShuttle", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingWaterMediumShuttle", 1)
    else
        RealSonar.GiveAffliction(character, "SonarPingWaterFarShuttle", 1)
    end
end
function RealSonar.waterSoundsShuttleDirectional(character, strength)
    if strength > 75 then
        RealSonar.GiveAffliction(character, "sonarPingWaterVeryCloseShuttleDirectional", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingWaterCloseShuttleDirectional", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingWaterMediumShuttleDirectional", 1)
    else
        RealSonar.GiveAffliction(character, "SonarPingWaterFarShuttleDirectional", 1)
    end
end

function RealSonar.suitSoundsShuttle(character, strength)
    if strength > 75 then
        RealSonar.GiveAffliction(character, "sonarPingSuitVeryCloseShuttle", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingSuitCloseShuttle", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingSuitMediumShuttle", 1)
    else
        RealSonar.GiveAffliction(character, "SonarPingSuitFarShuttle", 1)
    end
end
function RealSonar.suitSoundsShuttleDirectional(character, strength)
    if strength > 75 then
        RealSonar.GiveAffliction(character, "sonarPingSuitVeryCloseShuttleDirectional", 1)
    elseif strength > 50 then
        RealSonar.GiveAffliction(character, "sonarPingSuitCloseShuttleDirectional", 1)
    elseif strength > 25 then
        RealSonar.GiveAffliction(character, "sonarPingSuitMediumShuttleDirectional", 1)
    else
        RealSonar.GiveAffliction(character, "SonarPingSuitFarShuttleDirectional", 1)
    end
end
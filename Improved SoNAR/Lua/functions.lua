-- Returns true if there is a valid path from a hull breach to the character. Takes usually 0.00004 - 0.00015 seconds to run depending the amount of hulls.
function RealSonar.pathToBreach(character)
    if not character.AnimController.currentHull then
        return true
    end
    local hulls = character.AnimController.currentHull.GetConnectedHulls(true, 100, true)
    local hullCount = 0
    local waterFilledHulls = 0
    for hull in hulls do
        hullCount = hullCount + 1
        if hull.WaterPercentage >= 50 then
            waterFilledHulls = waterFilledHulls + 1
        end
        for gap in hull.ConnectedGaps do
            if gap.IsRoomToRoom == false and gap.open >= 0.4 and
            -- If water level is above the lower boundary of the gap .
            hull.Surface + hull.WaveY[#hull.WaveY - 1] > gap.rect.Y - gap.Size then
                -- If character position is below the gap.
                if character.Position.Y < gap.rect.Y - gap.Size then
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

-- Calculates the distance between two points in 2D space.
function RealSonar.distanceBetween(point1, point2)
    local xd = point1.X - point2.X
    local yd = point1.Y - point2.Y
    return math.sqrt(xd*xd + yd*yd)
end

-- The distance the character has to be relative to the sonar for it to be considered dangerous.
local dangerRange = {}
dangerRange["navterminal"] = 9000
dangerRange["sonarmonitor"] = 6000

-- Returns true if the character is dangerously close to any active sonar source.
-- Ideally this checks if the gap is in range instead of the character, but I can't find a way to pass it in.
function RealSonar.characterInSonarRange(character)
    local inSonar = false
    local sonar
    for item in RealSonar.sonarItems do
        sonar = item.GetComponentString("Sonar")
        if tostring(sonar.currentMode) == "Active" and sonar.Voltage > sonar.minVoltage and RealSonar.distanceBetween(item.worldPosition, character.worldPosition) <= dangerRange[item.Prefab.Identifier.Value] then
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

-- Returns true if the chaarcter is inside the direction ping sector.
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

function RealSonar.hasSonarResistance(character)
    local suit = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
    if not suit or not suit.HasTag("anechoic") then
        return false
    else
        return true
    end
end

function RealSonar.getSonarResistance(character, identifier)
    local suit = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
    local damageMultiplier = 1
    local wearable = suit.GetComponentString("Wearable")
    for modifier in wearable.DamageModifiers do
        if modifier.AfflictionIdentifiers == identifier then
            damageMultiplier = modifier.DamageMultiplier
            break
        end
    end
    return damageMultiplier
end

function RealSonar.GiveAffliction(character, identifier, strength)
    local prefab = AfflictionPrefab.Prefabs[identifier]
    local affliction = prefab.Instantiate(strength)
    character.CharacterHealth.ApplyAffliction(character.AnimController.GetLimb(LimbType.Torso), affliction, false)
end

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
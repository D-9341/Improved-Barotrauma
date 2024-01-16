-- Makes bots try to get an anechoic suit before repairing leaks when in dangerous range of an active sonar.
Hook.Patch(
    "Barotrauma.AIObjectiveGetItem",
    ".ctor",
    {
        "Barotrauma.Character",
        "Barotrauma.Identifier",
        "Barotrauma.AIObjectiveManager",
        "System.Boolean",
        "System.Boolean",
        "System.Single",
        "System.Boolean",
    },
    function(instance, ptable)

    local objective = ptable["objectiveManager"].GetActiveObjective()
    if tostring(objective) == "Barotrauma.AIObjectiveFindDivingGear" and RealSonar.characterInSonarRange(ptable["character"]) and RealSonar.hullBreached(ptable["character"]) then
        ptable["identifierOrTag"] = "anechoic"
    end
end, Hook.HookMethodType.Before)


-- Replace messages with custom ones relating to the situation.
Hook.Patch(
    "Barotrauma.Character",
    "Speak",
    function(instance, ptable)

    if tostring(ptable["identifier"]) == "getdivinggear" and RealSonar.characterInSonarRange(instance) and RealSonar.hullBreached(instance) then
        ptable["message"] = TextManager.Get("dialoggetanechoicsuit").Value

    elseif tostring(ptable["identifier"]) == "dialogcannotreachleak" and RealSonar.characterInSonarRange(instance) and RealSonar.hullBreached(instance) then
        ptable["delay"] = Single(2)
        ptable["message"] = TextManager.Get("dialogcantfindanechoicsuit").Value
    end
end, Hook.HookMethodType.Before)


-- Prevent bots from treating vibrationdamage/muscledamage with more than one manna extract at a time.
Hook.Patch(
    "Barotrauma.CharacterHealth",
    "GetPredictedStrength",
    {
        "Barotrauma.Affliction",
        "System.Single",
        "Barotrauma.Limb"
    },
    function(instance, ptable)
    
    if ptable["affliction"].Prefab.Identifier == "vibrationdamage" or ptable["affliction"].Prefab.Identifier == "muscledamage" then
        local vibrationdamage = false
        local muscledamage = false
        local mannainfluence = false
        local afflictions = instance.GetAllAfflictions()

        for affliction in afflictions do
            if affliction.Prefab.Identifier == "vibrationdamage" then
                vibrationdamage = true
            elseif affliction.Prefab.Identifier == "mannainfluence" then
                mannainfluence = true
            elseif affliction.Prefab.Identifier == "muscledamage" then
                muscledamage = true
            end
        end

        if mannainfluence and vibrationdamage or mannainfluence and muscledamage then
            ptable.PreventExecution = true
            return 0
        end
    end
end, Hook.HookMethodType.Before)
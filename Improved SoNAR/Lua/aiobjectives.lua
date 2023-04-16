
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


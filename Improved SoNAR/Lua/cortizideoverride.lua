local fx_preset
Hook.Add("item.applyTreatment", "fxcontrol", function(item, usingCharacter, targetCharacter, limb)
    if item.Prefab.Identifier == "cortizide" and limb == targetCharacter.AnimController.GetLimb(LimbType.Head) then
        fx_preset = RealSonar.getVFXPresetString()
        RealSonar.GiveAffliction(targetCharacter, string.format("cortizideinjection%s", fx_preset), 1)
    end
end)
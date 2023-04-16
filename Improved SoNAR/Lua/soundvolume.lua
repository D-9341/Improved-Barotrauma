Hook.Patch(
    "Barotrauma.SoundPlayer",
    "PlaySound",
    {
        "Barotrauma.Sounds.Sound",
        "Microsoft.Xna.Framework.Vector2",
        "System.Single",
        "System.Single",
        "System.Single",
        "Barotrauma.Hull",
        "System.Boolean"
    },
    function(instance, ptable)

    local sound = ptable["sound"]
    local soundName = sound.filename

    if string.find(soundName,"sonarPingWater") or string.find(soundName,"sonarTailWater") then
        ptable["volume"] = Single(ptable["volume"] * RealSonar.Settings.WaterPingVolume) or ptable["volume"]

    elseif string.find(soundName,"sonarPingAir") or string.find(soundName,"sonarTailAir") then
        ptable["volume"] = Single(ptable["volume"] * RealSonar.Settings.AirPingVolume) or ptable["volume"]

    elseif string.find(soundName,"sonarPingSuit") or string.find(soundName,"sonarTailSuit") then
        ptable["volume"] = Single(ptable["volume"] * RealSonar.Settings.SuitPingVolume) or ptable["volume"]
    end

    if string.find(soundName,"Tinnitus") then
        ptable["volume"] = Single(ptable["volume"] * RealSonar.Settings.TinnitusVolume) or ptable["volume"]
    end
    if string.find(soundName,"sonarDistortion") then
        ptable["volume"] = Single(ptable["volume"] * RealSonar.Settings.DistortionVolume) or ptable["volume"]
    end

end, Hook.HookMethodType.Before)
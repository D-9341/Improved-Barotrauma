local config = {}

-- Cosmetic.
config.WaterPingVolume = 1
config.SuitPingVolume = 1
config.AirPingVolume = 1
config.TinnitusVolume = 1
config.DistortionVolume = 1
config.ImpactVisuals = 1
config.VFXPreset = 2

-- Gameplay.
config.SonarRange = 1
config.SonarDamage = 1
config.SonarSlow = 1
config.SubmarineSonar = true
config.BeaconSonar = true
config.ShuttleSonar = true
config.CreatureDamage = true
config.PlayerDamage = true
config.BotDamage = true
config.HumanHullDetection = true
config.CreatureHullDetection = true
config.LowLatencyMode = false

config.IgnoredCharacters = {}
table.insert(config.IgnoredCharacters, "Put_ids_here")

config.WearableProtections = {}
config.WearableProtections["divingsuit"] = {}
config.WearableProtections["divingsuit"]["damageMultiplier"] = 0.1
config.WearableProtections["divingsuit"]["anechoic"] = false
config.WearableProtections["abyssdivingsuit"] = {}
config.WearableProtections["abyssdivingsuit"]["damageMultiplier"] = 0.2
config.WearableProtections["abyssdivingsuit"]["anechoic"] = false
config.WearableProtections["combatdivingsuit"] = {}
config.WearableProtections["combatdivingsuit"]["damageMultiplier"] = 0.05
config.WearableProtections["combatdivingsuit"]["anechoic"] = false
config.WearableProtections["respawndivingsuit"] = {}
config.WearableProtections["respawndivingsuit"]["damageMultiplier"] = 0.1
config.WearableProtections["respawndivingsuit"]["anechoic"] = false
config.WearableProtections["pucs"] = {}
config.WearableProtections["pucs"]["damageMultiplier"] = 0.25
config.WearableProtections["pucs"]["anechoic"] = false
config.WearableProtections["exosuit"] = {}
config.WearableProtections["exosuit"]["damageMultiplier"] = 0.9
config.WearableProtections["exosuit"]["anechoic"] = true
config.WearableProtections["clownexosuit"] = {}
config.WearableProtections["clownexosuit"]["damageMultiplier"] = 0.9
config.WearableProtections["clownexosuit"]["anechoic"] = true

return config
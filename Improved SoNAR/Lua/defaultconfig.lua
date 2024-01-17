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
config.CustomSonar = false
config.CreatureDamage = true
config.PlayerDamage = true
config.BotDamage = true
config.HumanHullDetection = true
config.CreatureHullDetection = true
config.LowLatencyMode = false

config.SonarTerminals = {}
config.SonarTerminals["navterminal"] = {}
config.SonarTerminals["navterminal"]["damage"] = "high"
config.SonarTerminals["navterminal"]["sounds"] = "default"
config.SonarTerminals["navterminal"]["range"] = 12000
config.SonarTerminals["shuttlenavterminal"] = {}
config.SonarTerminals["shuttlenavterminal"]["damage"] = "medium"
config.SonarTerminals["shuttlenavterminal"]["sounds"] = "shuttle"
config.SonarTerminals["shuttlenavterminal"]["range"] = 10000
config.SonarTerminals["sonarmonitor"] = {}
config.SonarTerminals["sonarmonitor"]["damage"] = "low"
config.SonarTerminals["sonarmonitor"]["sounds"] = "default"
config.SonarTerminals["sonarmonitor"]["range"] = 8000

config.IgnoredCharacters = {}
table.insert(config.IgnoredCharacters, "Put_ids_here")

config.WearableProtections = {}
config.WearableProtections["anechoicdivingsuit"] = {}
config.WearableProtections["anechoicdivingsuit"]["damageMultiplier"] = 0.4
config.WearableProtections["anechoicdivingsuit"]["anechoic"] = true
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
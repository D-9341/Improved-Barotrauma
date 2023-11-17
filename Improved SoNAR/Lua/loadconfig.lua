local configPath = RealSonar.Path .. "/config.json"
local defaultConfig = dofile(RealSonar.Path .. "/Lua/defaultconfig.lua")

if not File.Exists(configPath) then
    -- Create config with default values.
    RealSonar.Config = defaultConfig
    File.Write(configPath, json.serialize(RealSonar.Config))
else
    -- Load config.
    RealSonar.Config = json.parse(File.Read(configPath))

    -- Limit values in the case they are manually edited.
    if RealSonar.Config.SonarRange > 1.91 then
        RealSonar.Config.SonarRange = 1.91
    elseif RealSonar.Config.SonarRange < 0.1 then
        RealSonar.Config.SonarRange = 0.1
    end
    if RealSonar.Config.SonarDamage > 2 then
        RealSonar.Config.SonarDamage = 2
    elseif RealSonar.Config.SonarDamage < 0 then
        RealSonar.Config.SonarDamage = 0
    end
    if RealSonar.Config.SonarSlow > 1.5 then
        RealSonar.Config.SonarSlow = 1.5
    elseif RealSonar.Config.SonarSlow < 0.5 then
        RealSonar.Config.SonarSlow = 0.5
    end
    if RealSonar.Config.ImpactVisuals > 2 then
        RealSonar.Config.ImpactVisuals = 2
    elseif RealSonar.Config.ImpactVisuals < 0 then
        RealSonar.Config.ImpactVisuals = 0
    end
    RealSonar.Config.VFXPreset = math.floor(RealSonar.Config.VFXPreset)
    if RealSonar.Config.VFXPreset > 2 then
        RealSonar.Config.VFXPreset = 2
    elseif RealSonar.Config.VFXPreset < 0 then
        RealSonar.Config.VFXPreset = 0
    end

    -- Add missing values.
    for key, value in pairs(defaultConfig) do
        if RealSonar.Config[key] == nil then
            RealSonar.Config[key] = value
        end
    end
end

-- Package specific changes.
for package in ContentPackageManager.EnabledPackages.All do
    -- Real Sonar LITE.
    if tostring(package.UgcId) == "2938034581" then
        RealSonar.LITE = true
    -- Undersea Horrors or Barotraumatic Creature Pack.
    elseif tostring(package.UgcId) == "2667451351" or tostring(package.UgcId) == "2831987252" then
        table.insert(RealSonar.Config.IgnoredCharacters, "Mine")
        table.insert(RealSonar.Config.IgnoredCharacters, "Minedetached")
        table.insert(RealSonar.Config.IgnoredCharacters, "Minesmall")
        table.insert(RealSonar.Config.IgnoredCharacters, "Minemission")
        table.insert(RealSonar.Config.IgnoredCharacters, "Minedetachedmission")
        table.insert(RealSonar.Config.IgnoredCharacters, "Minesmallmission")
        table.insert(RealSonar.Config.IgnoredCharacters, "DeadnoughtHomingshell")
    end
end
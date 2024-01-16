local easySettings = dofile(RealSonar.Path .. "/Lua/easysettings.lua")
local MultiLineTextBox = dofile(RealSonar.Path .. "/Lua/multilinetextbox.lua")
local configPath = RealSonar.Path .. "/config.json"
local defaultConfig = dofile(RealSonar.Path .. "/Lua/defaultconfig.lua")

local function CommaStringToTable(str)
    local tbl = {}

    for word in string.gmatch(str, '([^, %s]+)') do
        table.insert(tbl, word)
    end

    return tbl
end

local function formatJsonTextBlock(str)
    local pattern = "},\""
    local replacement = "},\n\""

    -- Add newline after first character and before last character
    if #str > 1 then
        str = str:sub(1, 1) .. "\n" .. str:sub(2, -2) .. "\n" .. str:sub(-1)
    end

    return string.gsub(str, pattern, replacement)
end


easySettings.AddMenu(TextManager.Get("realsonarsettings").Value, function (parent)
    local list = easySettings.BasicList(parent)
    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), list.Content.RectTransform), TextManager.Get("volumesettings").Value, nil, nil, GUI.Alignment.Center)

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local slider = easySettings.Slider(list.Content, 0, 2, function (value)
        RealSonar.Config.AirPingVolume = math.floor(value * 100)/100
        textBlock.Text = string.format("%s %s%%", TextManager.Get("airpingvolume").Value, math.floor(value * 100))
        easySettings.SaveTable(configPath, RealSonar.Config)
    end, RealSonar.Config.AirPingVolume)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("airpingvolume").Value, math.floor(slider.BarScrollValue * 100))

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local slider = easySettings.Slider(list.Content, 0, 2, function (value)
        RealSonar.Config.WaterPingVolume = math.floor(value * 100)/100
        textBlock.Text = string.format("%s %s%%", TextManager.Get("waterpingvolume").Value, math.floor(value * 100))
        easySettings.SaveTable(configPath, RealSonar.Config)
    end, RealSonar.Config.WaterPingVolume)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("waterpingvolume").Value, math.floor(slider.BarScrollValue * 100))

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local slider = easySettings.Slider(list.Content, 0, 2, function (value)
        RealSonar.Config.SuitPingVolume = math.floor(value * 100)/100
        textBlock.Text = string.format("%s %s%%", TextManager.Get("suitpingvolume").Value, math.floor(value * 100))
        easySettings.SaveTable(configPath, RealSonar.Config)
    end, RealSonar.Config.SuitPingVolume)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("suitpingvolume").Value, math.floor(slider.BarScrollValue * 100))

    if RealSonar.LITE == false then
        local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
        local slider = easySettings.Slider(list.Content, 0, 2, function (value)
            RealSonar.Config.TinnitusVolume = math.floor(value * 100)/100
            textBlock.Text = string.format("%s %s%%", TextManager.Get("tinnitusvolume").Value, math.floor(value * 100))
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.TinnitusVolume)
        textBlock.Text = string.format("%s %s%%", TextManager.Get("tinnitusvolume").Value, math.floor(slider.BarScrollValue * 100))

        local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
        local slider = easySettings.Slider(list.Content, 0, 2, function (value)
            RealSonar.Config.DistortionVolume = math.floor(value * 100)/100
            textBlock.Text = string.format("%s %s%%", TextManager.Get("distortionvolume").Value, math.floor(value * 100))
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.DistortionVolume)
        textBlock.Text = string.format("%s %s%%", TextManager.Get("distortionvolume").Value, math.floor(slider.BarScrollValue * 100))
    end

    if Game.IsMultiplayer then
        GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
        GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), list.Content.RectTransform), TextManager.Get("networksettings").Value, nil, nil, GUI.Alignment.Center)
        local tick = easySettings.TickBox(list.Content, TextManager.Get("lowlatencymode"), function (state)
            RealSonar.Config.LowLatencyMode = state
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.LowLatencyMode)
        tick.ToolTip = TextManager.Get("lowlatencymodetooltip")
        GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
        GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), list.Content.RectTransform), TextManager.Get("gameplaysettingsserver").Value, nil, nil, GUI.Alignment.Center)
    else
        GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), list.Content.RectTransform), TextManager.Get("gameplaysettingsclient").Value, nil, nil, GUI.Alignment.Center)
    end

    if RealSonar.LITE == false then
        local tick = easySettings.TickBox(list.Content, TextManager.Get("submarinesonar"), function (state)
            RealSonar.Config.SubmarineSonar = state
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.SubmarineSonar)
        tick.ToolTip = TextManager.Get("submarinesonartooltip")

        local tick = easySettings.TickBox(list.Content, TextManager.Get("beaconsonar"), function (state)
            RealSonar.Config.BeaconSonar = state
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.BeaconSonar)
        tick.ToolTip = TextManager.Get("beaconsonartooltip")

        local tick = easySettings.TickBox(list.Content, TextManager.Get("shuttlesonar"), function (state)
            RealSonar.Config.ShuttleSonar = state
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.ShuttleSonar)
        tick.ToolTip = TextManager.Get("shuttlesonartooltip")

        local tick = easySettings.TickBox(list.Content, TextManager.Get("customsonar"), function (state)
            RealSonar.Config.CustomSonar = state
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.CustomSonar)
        tick.ToolTip = TextManager.Get("customsonartooltip")

        local tick = easySettings.TickBox(list.Content, TextManager.Get("targetcreatures"), function (state)
            RealSonar.Config.CreatureDamage = state
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.CreatureDamage)
        tick.ToolTip = TextManager.Get("targetcreaturestooltip")

        local tick = easySettings.TickBox(list.Content, TextManager.Get("targetbots"), function (state)
            RealSonar.Config.BotDamage = state
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.BotDamage)
        tick.ToolTip = TextManager.Get("targetbotstooltip")
    end

    local tick = easySettings.TickBox(list.Content, TextManager.Get("targetplayers"), function (state)
        RealSonar.Config.PlayerDamage = state
        easySettings.SaveTable(configPath, RealSonar.Config)
    end, RealSonar.Config.PlayerDamage)
    tick.ToolTip = TextManager.Get("targetplayerstooltip")

    local tick = easySettings.TickBox(list.Content, TextManager.Get("humanhulldetection"), function (state)
        RealSonar.Config.HumanHullDetection = state
        easySettings.SaveTable(configPath, RealSonar.Config)
    end, RealSonar.Config.HumanHullDetection)
    tick.ToolTip = TextManager.Get("humanhulldetectiontooltip")

    local tick = easySettings.TickBox(list.Content, TextManager.Get("creaturehulldetection"), function (state)
        RealSonar.Config.CreatureHullDetection = state
        easySettings.SaveTable(configPath, RealSonar.Config)
    end, RealSonar.Config.CreatureHullDetection)
    tick.ToolTip = TextManager.Get("creaturehulldetectiontooltip")

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local rangeStartingValue = RealSonar.Config.SonarRange
    local slider = easySettings.Slider(list.Content, 0.1, 1.91, function (value)
        RealSonar.Config.SonarRange = math.floor(value * 100)/100
        textBlock.Text = string.format("%s %s%%", TextManager.Get("sonarrange").Value, math.floor(value * 100))
        easySettings.SaveTable(configPath, RealSonar.Config)
        if RealSonar.Config.SonarRange ~= rangeStartingValue then
            easySettings.needRangeUpdate = true
        else
            easySettings.needRangeUpdate = false
        end
        
    end, RealSonar.Config.SonarRange)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("sonarrange").Value, math.floor(slider.BarScrollValue * 100))

    if RealSonar.LITE == false then
        local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
        local slider = easySettings.Slider(list.Content, 0, 2, function (value)
            RealSonar.Config.SonarDamage = math.floor(value * 100)/100
            textBlock.Text = string.format("%s %s%%", TextManager.Get("sonardamage").Value, math.floor(value * 100))
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.SonarDamage)
        textBlock.Text = string.format("%s %s%%", TextManager.Get("sonardamage").Value, math.floor(slider.BarScrollValue * 100))

        local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
        local slider = easySettings.Slider(list.Content, 0.5, 1.5, function (value)
            RealSonar.Config.SonarSlow = math.floor(value * 100)/100
            textBlock.Text = string.format("%s %s%%", TextManager.Get("sonarslow").Value, math.floor(value * 100))
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.SonarSlow)
        textBlock.Text = string.format("%s %s%%", TextManager.Get("sonarslow").Value, math.floor(slider.BarScrollValue * 100))
        
        local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
        local slider = easySettings.Slider(list.Content, 0, 2, function (value)
            RealSonar.Config.ImpactVisuals = math.floor(value * 100)/100
            textBlock.Text = string.format("%s %s%%", TextManager.Get("impactvisuals").Value, math.floor(value * 100))
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.ImpactVisuals)
        textBlock.Text = string.format("%s %s%%", TextManager.Get("impactvisuals").Value, math.floor(slider.BarScrollValue * 100))
        
        local title
        if RealSonar.Config.VFXPreset == 2 then
            title = "defaultfx"
        elseif RealSonar.Config.VFXPreset == 1 then
            title = "lowfx"
        elseif RealSonar.Config.VFXPreset >= 0 then
            title = "nofx"
        end
        local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
        local slider = easySettings.Slider(list.Content, 0, 2, function (value)
            RealSonar.Config.VFXPreset = math.floor(value + 0.5)
            if RealSonar.Config.VFXPreset == 2 then
                title = "defaultfx"
            elseif RealSonar.Config.VFXPreset == 1 then
                title = "lowfx"
            elseif RealSonar.Config.VFXPreset >= 0 then
                title = "nofx"
            end
            textBlock.Text = string.format("%s", TextManager.Get(title).Value)
            easySettings.SaveTable(configPath, RealSonar.Config)
        end, RealSonar.Config.VFXPreset)
        textBlock.Text = string.format("%s", TextManager.Get(title).Value)
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), TextManager.Get("ignoredcharacters").Value, nil, nil, GUI.Alignment.Center, true)
    local ignoredCharacters = MultiLineTextBox(list.Content.RectTransform, "", 0.1)
    ignoredCharacters.Text = table.concat(RealSonar.Config.IgnoredCharacters, ", ")
    ignoredCharacters.OnTextChangedDelegate = function (textBox)
        RealSonar.Config.IgnoredCharacters = CommaStringToTable(textBox.Text)
        easySettings.SaveTable(configPath, RealSonar.Config)
    end

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), TextManager.Get("wearableprotections").Value, nil, nil, GUI.Alignment.Center, true)
    local wearableProtections = MultiLineTextBox(list.Content.RectTransform, "", 0.2)
    local startingWearables = 0
    local newWearables = 0
    for _ in RealSonar.Config.WearableProtections do
        startingWearables = startingWearables + 1
    end
    wearableProtections.Text = formatJsonTextBlock(json.serialize(RealSonar.Config.WearableProtections))
    wearableProtections.OnTextChangedDelegate = function (textBox)
        if pcall(json.parse, textBox.Text) then
            RealSonar.Config.WearableProtections = json.parse(textBox.Text)
            easySettings.SaveTable(configPath, RealSonar.Config)
            textBlock.Text = TextManager.Get("wearableprotections").Value
            for _ in RealSonar.Config.SonarTerminals do
                newWearables = newWearables + 1
            end
            if newWearables > startingWearables then
                easySettings.needWearableProtectionsUpdate = true
            end
        else
            textBlock.Text = string.format("%s (%s)", TextManager.Get("wearableprotections").Value, TextManager.Get("invalidinput").Value)
        end
    end
    local btn = GUI.Button(GUI.RectTransform(Vector2(1, 0.2), list.Content.RectTransform), TextManager.Get("resetdefault").Value, GUI.Alignment.Center, "GUIButtonSmall")
    btn.OnClicked = function ()
        RealSonar.Config.WearableProtections = defaultConfig.WearableProtections
        File.Write(configPath, json.serialize(RealSonar.Config))
        wearableProtections.Text = formatJsonTextBlock(json.serialize(RealSonar.Config.WearableProtections))
    end

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center, true)
    local sonarTerminals = MultiLineTextBox(list.Content.RectTransform, "", 0.2)
    local warningText = ""
    local startingTerminals = 0
    local newTerminals = 0
    for _ in RealSonar.Config.SonarTerminals do
        startingTerminals = startingTerminals + 1
    end

    if not RealSonar.Config.CustomSonar then
        warningText = TextManager.Get("requirescustomsonar").Value
    end
    textBlock.Text = string.format("%s %s", TextManager.Get("sonarterminals").Value, warningText)
    sonarTerminals.Text = formatJsonTextBlock(json.serialize(RealSonar.Config.SonarTerminals))
    sonarTerminals.OnTextChangedDelegate = function (textBox)
        if pcall(json.parse, textBox.Text) then
            RealSonar.Config.SonarTerminals = json.parse(textBox.Text)
            easySettings.SaveTable(configPath, RealSonar.Config)
            textBlock.Text = string.format("%s %s",TextManager.Get("sonarterminals").Value, warningText)
            easySettings.needRangeUpdate = true
            for _ in RealSonar.Config.SonarTerminals do
                newTerminals = newTerminals + 1
            end
            if newTerminals > startingTerminals then
                easySettings.needSonarItemsUpdate = true
            end
        else
            textBlock.Text = string.format("%s %s (%s)", TextManager.Get("sonarterminals").Value, warningText, TextManager.Get("invalidinput").Value)
        end
    end

    local btn = GUI.Button(GUI.RectTransform(Vector2(1, 0.2), list.Content.RectTransform), TextManager.Get("resetdefault").Value, GUI.Alignment.Center, "GUIButtonSmall")
    btn.OnClicked = function ()
        RealSonar.Config.SonarTerminals = defaultConfig.SonarTerminals
        File.Write(configPath, json.serialize(RealSonar.Config))
        sonarTerminals.Text = formatJsonTextBlock(json.serialize(RealSonar.Config.SonarTerminals))
        easySettings.needRangeUpdate = true
    end

end)
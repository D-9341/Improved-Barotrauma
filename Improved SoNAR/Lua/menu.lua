local easySettings = dofile(RealSonar.Path .. "/Lua/easysettings.lua")
local configPath = RealSonar.Path .. "/config.json"

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
end)
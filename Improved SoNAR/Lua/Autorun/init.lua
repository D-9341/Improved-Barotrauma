LuaUserData.RegisterType("Barotrauma.DamageModifier")
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Items.Components.Sonar"], "pingDirection")

RealSonar = {}
RealSonar.Path = table.pack(...)[1]
RealSonar.sonarItems = {}

dofile(RealSonar.Path .. "/Lua/functions.lua")
dofile(RealSonar.Path .. "/Lua/aiobjectives.lua")
dofile(RealSonar.Path .. "/Lua/getsonaritems.lua")
dofile(RealSonar.Path .. "/Lua/anechoicsuit.lua")
dofile(RealSonar.Path .. "/Lua/sonarping.lua")

-- Client-side menu.
if SERVER then return end

dofile(RealSonar.Path .. "/Lua/soundvolume.lua")

local easySettings = dofile(RealSonar.Path .. "/Lua/easysettings.lua")
RealSonar.Settings = easySettings.LoadTable(RealSonar.Path .. "/settings.json")

easySettings.AddMenu(TextManager.Get("realsonarsettings").Value, function (parent)
    local list = easySettings.BasicList(parent)
    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), list.Content.RectTransform), TextManager.Get("sonarpingvolume").Value, nil, nil, GUI.Alignment.Center)

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local slider = easySettings.Slider(list.Content, 0, 2, function (value)
        RealSonar.Settings.AirPingVolume = value
        textBlock.Text = string.format("%s %s%%", TextManager.Get("airpingvolume").Value, math.floor(value * 100))
        easySettings.SaveTable(RealSonar.Path .. "/settings.json", RealSonar.Settings)
    end, RealSonar.Settings.AirPingVolume)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("airpingvolume").Value, math.floor(slider.BarScrollValue * 100))

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local slider = easySettings.Slider(list.Content, 0, 2, function (value)
        RealSonar.Settings.WaterPingVolume = value
        textBlock.Text = string.format("%s %s%%", TextManager.Get("waterpingvolume").Value, math.floor(value * 100))
        easySettings.SaveTable(RealSonar.Path .. "/settings.json", RealSonar.Settings)
    end, RealSonar.Settings.WaterPingVolume)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("waterpingvolume").Value, math.floor(slider.BarScrollValue * 100))

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local slider = easySettings.Slider(list.Content, 0, 2, function (value)
        RealSonar.Settings.SuitPingVolume = value
        textBlock.Text = string.format("%s %s%%", TextManager.Get("suitpingvolume").Value, math.floor(value * 100))
        easySettings.SaveTable(RealSonar.Path .. "/settings.json", RealSonar.Settings)
    end, RealSonar.Settings.SuitPingVolume)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("suitpingvolume").Value, math.floor(slider.BarScrollValue * 100))

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local slider = easySettings.Slider(list.Content, 0, 2, function (value)
        RealSonar.Settings.TinnitusVolume = value
        textBlock.Text = string.format("%s %s%%", TextManager.Get("tinnitusvolume").Value, math.floor(value * 100))
        easySettings.SaveTable(RealSonar.Path .. "/settings.json", RealSonar.Settings)
    end, RealSonar.Settings.TinnitusVolume)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("tinnitusvolume").Value, math.floor(slider.BarScrollValue * 100))

    local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), list.Content.RectTransform), "", nil, nil, GUI.Alignment.Center)
    local slider = easySettings.Slider(list.Content, 0, 2, function (value)
        RealSonar.Settings.DistortionVolume = value
        textBlock.Text = string.format("%s %s%%", TextManager.Get("distortionvolume").Value, math.floor(value * 100))
        easySettings.SaveTable(RealSonar.Path .. "/settings.json", RealSonar.Settings)
    end, RealSonar.Settings.DistortionVolume)
    textBlock.Text = string.format("%s %s%%", TextManager.Get("distortionvolume").Value, math.floor(slider.BarScrollValue * 100))
end)
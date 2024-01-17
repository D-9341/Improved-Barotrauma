-- This code was adapted from EvilFactory's LuaAudioOverhaul mod.
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2868921484

local easySettings = {}
local configPath = RealSonar.Path .. "/config.json"
local defaultConfig = dofile(RealSonar.Path .. "/Lua/defaultconfig.lua")
easySettings.Settings = {}
easySettings.needRangeUpdate = false
easySettings.needSonarItemsUpdate = false
easySettings.needWearableProtectionsUpdate = false

local GUIComponent = LuaUserData.CreateStatic("Barotrauma.GUIComponent")

local function GetChildren(comp)
    local tbl = {}
    for value in comp.GetAllChildren() do
        table.insert(tbl, value)
    end
    return tbl
end

Hook.Patch("Barotrauma.GUI", "TogglePauseMenu", {}, function ()
    if GUI.GUI.PauseMenuOpen then
        local frame = GUI.GUI.PauseMenu

        local list = GetChildren(GetChildren(frame)[2])[1]

        for key, value in pairs(easySettings.Settings) do
            local button = GUI.Button(GUI.RectTransform(Vector2(1, 0.1), list.RectTransform), value.Name, GUI.Alignment.Center, "GUIButtonSmall")

            button.OnClicked = function ()
                value.OnOpen(frame)
            end
        end
    -- The else block runs on menu close.
    else
        if Game.IsMultiplayer then
            local message = Networking.Start("reloadserverconfig")
            Networking.Send(message)
        end

        if easySettings.needSonarItemsUpdate then
            if Game.IsMultiplayer then
                local message = Networking.Start("getsonaritems")
                Networking.Send(message)
            else
                RealSonar.getSonarItems()
            end
            easySettings.needSonarItemsUpdate = false
        end

        if easySettings.needWearableProtectionsUpdate then
            if Game.IsMultiplayer then
                local message = Networking.Start("setitemtags")
                Networking.Send(message)
            else
                RealSonar.setItemTags()
            end
            easySettings.needWearableProtectionsUpdate = false
        end

        if not Game.IsMultiplayer and easySettings.needRangeUpdate then
            RealSonar.setSonarRanges()
            easySettings.needRangeUpdate = false
        end
    end
end, Hook.HookMethodType.After)

easySettings.SaveTable = function (path, tbl)
    File.Write(path, json.serialize(tbl))
end
easySettings.LoadTable = function (path)
    if not File.Exists(path) then
        return {}
    end

    return json.parse(File.Read(path))
end

easySettings.AddMenu = function (name, onOpen)
    table.insert(easySettings.Settings, {Name = name, OnOpen = onOpen})
end

easySettings.BasicList = function (parent, size)
    local menuContent = GUI.Frame(GUI.RectTransform(size or Vector2(0.3, 0.5), parent.RectTransform, GUI.Anchor.Center))
    local menuList = GUI.ListBox(GUI.RectTransform(Vector2(0.9, 0.8), menuContent.RectTransform, GUI.Anchor.Center))

    easySettings.CloseButton(menuContent)
    easySettings.ResetButton(menuContent)

    return menuList
end

easySettings.Slider = function (parent, min, max, onSelected, value)
    local scrollBar = GUI.ScrollBar(GUI.RectTransform(Vector2(1, 0.1), parent.RectTransform), 0.1, nil, "GUISlider")
    scrollBar.Range = Vector2(min, max)
    scrollBar.BarScrollValue = value or max / 2
    scrollBar.OnMoved = function ()
        onSelected(scrollBar.BarScrollValue)
    end

    return scrollBar
end

easySettings.TickBox = function (parent, text, onSelected, state)
    if state == nil then state = true end

    local tickBox = GUI.TickBox(GUI.RectTransform(Vector2(1, 0.2), parent.RectTransform), text)
    tickBox.Selected = state
    tickBox.OnSelected = function ()
        onSelected(tickBox.State == GUIComponent.ComponentState.Selected)
    end

    return tickBox
end

easySettings.CloseButton = function (parent)
    local button = GUI.Button(GUI.RectTransform(Vector2(0.5, 0.05), parent.RectTransform, GUI.Anchor.BottomRight), TextManager.Get("close").Value, GUI.Alignment.Center, "GUIButton")

    button.OnClicked = function ()
        GUI.GUI.TogglePauseMenu()
    end

    return button
end

easySettings.ResetButton = function (parent)
    local button = GUI.Button(GUI.RectTransform(Vector2(0.5, 0.05), parent.RectTransform, GUI.Anchor.BottomLeft), TextManager.Get("resetalldefault").Value, GUI.Alignment.Center, "GUIButton")

    button.OnClicked = function ()
        RealSonar.Config = dofile(RealSonar.Path .. "/Lua/defaultconfig.lua")
        File.Write(configPath, json.serialize(RealSonar.Config))
        easySettings.needRangeUpdate = true
        GUI.GUI.TogglePauseMenu()
    end

    return button
end

return easySettings
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Sounds.SoundManager"], "playingChannels")
Hook.Add("stop", "stopSounds", function()
    for side in Game.SoundManager.playingChannels do
        for channel in side do
            if string.find(channel.ToString(), "Tinnitus") or string.find(channel.ToString(), "brainHemorrhageStage") then
                channel.FadeOutAndDispose()
            end
        end
    end
end)
-- Note: This hook is not called if the diving suit is dragged and dropped out of the equipped slot.
--       This doesn't really matter because the paramaters will be corrected on the next interaction with an item.

Hook.Add("item.equip", "updateAnechoicParams", function(item, character)
    if character.Params.hideInSonar == false then
        local suit = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
        if suit and suit.Prefab.Identifier.Value == "anechoicdivingsuit" then
            character.Params.hideInSonar = true
            character.Params.HideInThermalGoggles = true
            character.Params.Noise = 80
            character.Params.Visibility = 40
        end
    else
        local suit = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
        -- Reset to default values if no longer wearing the suit.
        if not suit or suit.Prefab.Identifier.Value ~= "anechoicdivingsuit" then
            character.Params.hideInSonar = false
            character.Params.HideInThermalGoggles = false
            character.Params.Noise = 150
            character.Params.Visibility = 150
        end
    end
end)
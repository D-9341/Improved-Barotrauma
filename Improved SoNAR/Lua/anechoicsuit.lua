
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
        if not suit or suit.Prefab.Identifier.Value ~= "anechoicdivingsuit" then
            character.Params.hideInSonar = false
            character.Params.HideInThermalGoggles = false
            character.Params.Noise = 150
            character.Params.Visibility = 150
        end
    end
end)
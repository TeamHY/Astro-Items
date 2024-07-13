AstroItems.Collectible.MIRROR_DICE = Isaac.GetItemIdByName("Mirror Dice")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.MIRROR_DICE,
        "거울 주사위",
        "...",
        "사용 시 방 안에 모든 아이템이 현재 소지 중인 아이템으로 변경됩니다. 동일한 아이템이 여러개 등장할 수 있습니다. 보유한 아이템이 없을 경우 사용할 수 없습니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local inventory = AstroItems:getPlayerInventory(playerWhoUsedItem, false)

        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local pickup = entity:ToPickup()
                local item = AstroItems:GetRandomCollectibles(inventory, rngObj, 5, AstroItems.Collectible.MIRROR_DICE, true)[1]

                if not item then
                    return {
                        Discharge = false,
                        Remove = false,
                        ShowAnim = false,
                    }
                end

                pickup:Morph(pickup.Type, pickup.Variant, item, true)
            end
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.MIRROR_DICE
)

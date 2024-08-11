AstroItems.Collectible.RESTOCK_DICE = Isaac.GetItemIdByName("Restock Dice")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.RESTOCK_DICE,
        "리스톡 주사위",
        "사용 시 빈 아이템 테이블에 현재 방 배열 아이템을 소환합니다.",
        ""
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
        local itemPool = Game():GetItemPool()
        local room = Game():GetRoom()
        
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType == 0 then
                local pickup = entity:ToPickup()

                local item = itemPool:GetCollectible(itemPool:GetPoolForRoom(room:GetType(), rngObj:GetSeed()), true, rngObj:GetSeed(), CollectibleType.COLLECTIBLE_BREAKFAST)

                pickup:Morph(pickup.Type, pickup.Variant, item, true)
            end
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.RESTOCK_DICE
)

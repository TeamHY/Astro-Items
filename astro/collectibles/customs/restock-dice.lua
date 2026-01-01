Astro.Collectible.RESTOCK_DICE = Isaac.GetItemIdByName("Restock Dice")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.RESTOCK_DICE,
        "재활용 주사위",
        "운명을 다시 써라",
        "사용 시 빈 받침대에 그 방의 배열의 아이템을 소환합니다."
    )
end

Astro:AddCallback(
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
                local itemPoolType = itemPool:GetPoolForRoom(room:GetType(), rngObj:GetSeed())

                if itemPoolType == ItemPoolType.POOL_NULL then
                    itemPoolType = ItemPoolType.POOL_TREASURE
                end

                local item = itemPool:GetCollectible(itemPoolType, true, rngObj:GetSeed(), CollectibleType.COLLECTIBLE_BREAKFAST)

                entity:ToPickup():Morph(entity.Type, entity.Variant, item, true)
                Game():SpawnParticles(entity.Position, EffectVariant.POOF01, 1, 0)
                SFXManager():Play(910)
            end
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.RESTOCK_DICE
)

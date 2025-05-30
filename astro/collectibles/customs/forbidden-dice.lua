Astro.Collectible.FORBIDDEN_DICE = Isaac.GetItemIdByName("Forbidden Dice")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.FORBIDDEN_DICE,
        "금지된 주사위",
        "...",
        "사용 시 그 방의 아이템을 다른 아이템으로 바꿉니다."..
        "#{{ArrowGrayRight}} 액티브 아이템 등장 시 다시 바꿉니다."
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
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType ~= 0 then
                ---@type CollectibleType?
                local item = nil

                while not item do
                    local itemPoolType = itemPool:GetPoolForRoom(room:GetType(), rngObj:GetSeed())

                    if itemPoolType == ItemPoolType.POOL_NULL then
                        itemPoolType = ItemPoolType.POOL_TREASURE
                    end

                    item = itemPool:GetCollectible(itemPoolType, true, rngObj:GetSeed(), CollectibleType.COLLECTIBLE_BREAKFAST)

                    if item == CollectibleType.COLLECTIBLE_BREAKFAST then
                        break
                    end

                    if Isaac.GetItemConfig():GetCollectible(item).Type == ItemType.ITEM_ACTIVE then
                        print("Forbidden Dice: " .. item)
                        item = nil
                    end
                end

                entity:ToPickup():Morph(entity.Type, entity.Variant, item, true)
            end
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.FORBIDDEN_DICE
)

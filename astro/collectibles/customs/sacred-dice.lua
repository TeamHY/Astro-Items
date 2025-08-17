Astro.Collectible.SACRED_DICE = Isaac.GetItemIdByName("Sacred Dice")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SACRED_DICE,
        "성스러운 주사위",
        "위대한 운명으로",
        "사용 시 그 방의 아이템을 다른 아이템으로 바꿉니다."..
        "#{{ArrowGrayRight}} {{Quality0}}/{{Quality1}}등급 아이템 등장 시 다시 바꿉니다."..
        "#{{ArrowGrayRight}} {{Quality2}}등급 아이템 등장 시 20% 확률로 다시 바꿉니다."
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

                    local quality = Isaac.GetItemConfig():GetCollectible(item).Quality

                    if quality == 0 or quality == 1 then
                        print("Sacred Dice: " .. item)
                        item = nil
                    elseif quality == 2 then
                        if rngObj:RandomFloat() < 0.2 then
                            print("Sacred Dice: " .. item)
                            item = nil
                        end
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
    Astro.Collectible.SACRED_DICE
)

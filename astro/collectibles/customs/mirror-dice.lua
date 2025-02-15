Astro.Collectible.MIRROR_DICE = Isaac.GetItemIdByName("Mirror Dice")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.MIRROR_DICE,
        "거울 주사위",
        "...",
        "사용 시 방 안에 모든 아이템이 현재 소지 중인 아이템으로 변경됩니다. {{Quality0}}0등급/{{Quality1}}1등급 아이템은 등장하지 않습니다. 동일한 아이템이 여러개 등장할 수 있습니다. 보유한 아이템이 없을 경우 사용할 수 없습니다."
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
        local inventory = Astro:getPlayerInventory(playerWhoUsedItem, false)

        local itemList = Astro:FilterInventory(inventory, function(item)
            local itemConfig = Isaac.GetItemConfig():GetCollectible(item)
            return itemConfig.Quality > 1
        end)

        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local pickup = entity:ToPickup()
                
                if pickup.SubType ~= 0 then
                    local item = Astro:GetRandomCollectibles(itemList, rngObj, 1, Astro.Collectible.MIRROR_DICE, true)[1]

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
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.MIRROR_DICE
)

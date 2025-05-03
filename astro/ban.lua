Astro.LatterStageBanItems = {
    collectible = {
        CollectibleType.COLLECTIBLE_1UP,
    },
    trinket = {
    }
}

if EID then
    EID:addDescriptionModifier(
        "AstroLatterStageBan",
        function(descObj)
            if descObj.ObjType == EntityType.ENTITY_PICKUP and (descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE or descObj.ObjVariant == PickupVariant.PICKUP_TRINKET) then
                return true
            end
        end,
        function(descObj)
            if descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE then
                for _, collectible in ipairs(Astro.LatterStageBanItems.collectible) do
                    if descObj.ObjSubType == collectible then
                        EID:appendToDescription(descObj, "#!!! {{ColorRed}}9 스테이지 이후 아이템이 제거됩니다.")
                        break
                    end
                end
            elseif descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
                for _, trinket in ipairs(Astro.LatterStageBanItems.trinket) do
                    if descObj.ObjSubType == trinket then
                        EID:appendToDescription(descObj, "#!!! {{ColorRed}}9 스테이지 이후 아이템이 제거됩니다.")
                        break
                    end
                end
            end

            return descObj
        end
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Astro:IsLatterStage() then
            local itemPool = Game():GetItemPool()

            for _, collectible in ipairs(Astro.LatterStageBanItems.collectible) do
                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)
                
                    Astro:RemoveAllCollectible(player, collectible)
                end

                itemPool:RemoveCollectible(collectible)
            end

            for _, trinket in ipairs(Astro.LatterStageBanItems.trinket) do
                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)
                
                    Astro:RemoveAllTrinket(player, trinket)
                end

                itemPool:RemoveTrinket(trinket)
            end
        end
    end
)


Astro:AddCallback(
    Astro.Callbacks.POST_ITEM_PICKUP,
    ---@param player EntityPlayer
    ---@param pickingUpItem { itemType: ItemType, subType: CollectibleType | TrinketType }
    function(_, player, pickingUpItem)
        if Astro:IsLatterStage() then
            if pickingUpItem.itemType ~= ItemType.ITEM_TRINKET then
                for _, collectible in ipairs(Astro.LatterStageBanItems.collectible) do
                    if collectible == pickingUpItem.subType then
                        Astro:RemoveAllCollectible(player, collectible)
                        break
                    end
                end
            else
                for _, trinket in ipairs(Astro.LatterStageBanItems.trinket) do
                    if trinket == pickingUpItem.subType then
                        Astro:RemoveAllTrinket(player, trinket)
                        break
                    end
                end
            end
        end
    end
)

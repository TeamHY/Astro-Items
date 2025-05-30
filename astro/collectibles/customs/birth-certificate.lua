Astro.Collectible.BIRTH_CERTIFICATE = Isaac.GetItemIdByName("Birth Certificate")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BIRTH_CERTIFICATE,
        "출생증명서",
        "...",
        "사용 시 {{Quality2}}등급 이하의 아이템이 있는 방으로 이동합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.BirthCertificateUsed = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, UseFlag.USE_NOANIM, 0)

        Astro.Data.BirthCertificateUsed = true

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.BIRTH_CERTIFICATE
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro.Data.BirthCertificateUsed and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then 
            local itemConfig = Isaac.GetItemConfig()
            
            if itemConfig:GetCollectible(pickup.SubType).Quality > 2 then
                pickup:Remove()
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_ITEM_PICKUP,
    ---@param player EntityPlayer
    ---@param pickingUpItem { itemType: ItemType, subType: CollectibleType | TrinketType }
    function(_, player, pickingUpItem)
        if pickingUpItem.itemType ~= ItemType.ITEM_TRINKET then
            Astro.Data.BirthCertificateUsed = false
        end
    end
)

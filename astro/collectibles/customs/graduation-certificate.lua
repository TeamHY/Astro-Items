Astro.Collectible.GRADUATION_CERTIFICATE = Isaac.GetItemIdByName("Graduation Certificate")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.GRADUATION_CERTIFICATE,
                "졸업증명서",
                "안녕은 영원한 헤어짐은 아니겠지요",
                "사용 시 소지중인 아이템이 있는 방으로 이동합니다." ..
                "#{{ArrowGrayRight}} 아이템 하나 획득 시 원래 있던 장소로 돌아갑니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.GraduationCertificateUsed = false
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

        Astro.Data.GraduationCertificateUsed = true

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.GRADUATION_CERTIFICATE
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro.Data.GraduationCertificateUsed and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            if not Astro:HasCollectible(pickup.SubType) then
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
            Astro.Data.GraduationCertificateUsed = false
        end
    end
)

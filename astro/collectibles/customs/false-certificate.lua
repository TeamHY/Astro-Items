Astro.Collectible.FALSE_CERTIFICATE = Isaac.GetItemIdByName("False Certificate")

local FALSE_CERTIFICATE_ITEMS = {
    13,
    15,
    30,
    31,
    40,
    45,
    49,
    51,
    53,
    67,
    72,
    73,
    79,
    80,
    82,
    96,
    105,
    109,
    110,
    118,
    119,
    122,
    135,
    137,
    157,
    159,
    166,
    167,
    176,
    177,
    193,
    208,
    214,
    230,
    247,
    253,
    254,
    261,
    276,
    289,
    334,
    394,
    399,
    411,
    412,
    421,
    435,
    452,
    466,
    475,
    481,
    506,
    511,
    531,
    541,
    554,
    556,
    565,
    572,
    573,
    580,
    606,
    607,
    614,
    616,
    618,
    621,
    637,
    650,
    654,
    657,
    671,
    682,
    684,
    692,
    694,
    695,
    700,
    702,
    703,
    704,
    705,
    706,
    711,
    724,
    726,
    728,
    Astro.Collectible.AMAZING_CHAOS_SCROLL,
    Astro.Collectible.AMPLIFYING_MIND,
    Astro.Collectible.BIRTHRIGHT_APOLLYON_B,
    Astro.Collectible.BIRTHRIGHT_EVE,
    Astro.Collectible.BLOOD_OF_HATRED,
    Astro.Collectible.BLOOD_TRAIL,
    Astro.Collectible.BOMB_IS_POWER,
    Astro.Collectible.CALM_MIND,
    Astro.Collectible.CURSED_HEART,
    Astro.Collectible.FALLEN_ORB,
    Astro.Collectible.GALACTIC_MEDAL_OF_VALOR,
    Astro.Collectible.FORBIDDEN_DICE,
    Astro.Collectible.KEY_IS_POWER,
    Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE,
    Astro.Collectible.PINK_WARD,
    Astro.Collectible.RED_CUBE,
    Astro.Collectible.RESTOCK_DICE,
    Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE,
    Astro.Collectible.SNAKE_EYES_POPLAR,
    Astro.Collectible.UNHOLY_MANTLE,
    Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL,

}

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.FALSE_CERTIFICATE,
        "위조증명서",
        "공문서 위조는 중범죄입니다",
        "붉은 특급 비밀방 아이템이 존재하는 방으로 이동됩니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.FalseCertificateUsed = false
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

        Astro.Data.FalseCertificateUsed = true

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.FALSE_CERTIFICATE
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro.Data.FalseCertificateUsed and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then             
            if not Astro:Contain(FALSE_CERTIFICATE_ITEMS, pickup.SubType) then
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
            Astro.Data.FalseCertificateUsed = false
        end
    end
)

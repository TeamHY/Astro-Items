Astro.Collectible.FALSE_CERTIFICATE = Isaac.GetItemIdByName("False Certificate")

local FALSE_CERTIFICATE_ITEMS = {
    3,
    4,
    7,
    46,
    48,
    51,
    52,
    67,
    68,
    70,
    79,
    80,
    81,
    82,
    100,
    104,
    109,
    114,
    115,
    118,
    120,
    122,
    132,
    133,
    134,
    145,
    150,
    151,
    153,
    157,
    159,
    164,
    168,
    169,
    182,
    183,
    192,
    212,
    215,
    216,
    217,
    221,
    224,
    228,
    230,
    232,
    234,
    237,
    244,
    245,
    251,
    259,
    260,
    268,
    275,
    305,
    307,
    310,
    311,
    313,
    330,
    331,
    336,
    337,
    345,
    350,
    358,
    359,
    360,
    369,
    370,
    373,
    381,
    387,
    390,
    395,
    408,
    409,
    411,
    415,
    417,
    418,
    425,
    443,
    453,
    461,
    462,
    472,
    479,
    494,
    495,
    496,
    498,
    503,
    506,
    514,
    524,
    531,
    532,
    533,
    549,
    553,
    560,
    569,
    577,
    581,
    588,
    589,
    596,
    600,
    601,
    616,
    617,
    619,
    621,
    622,
    628,
    633,
    643,
    651,
    654,
    665,
    678,
    684,
    691,
    695,
    698,
    728,
    Astro.Collectible.CYGNUS,
    Astro.Collectible.LIBRA_EX,
    Astro.Collectible.CANCER_EX,
    Astro.Collectible.SCORPIO_EX,
    Astro.Collectible.CAPRICORN_EX,
    Astro.Collectible.VIRGO_EX,
    Astro.Collectible.LEO_EX,
    Astro.Collectible.ARIES_EX,
    Astro.Collectible.TAURUS_EX,
    Astro.Collectible.AQUARIUS_EX,
    Astro.Collectible.CORVUS,
    Astro.Collectible.PAVO,
    Astro.Collectible.COMET,
    Astro.Collectible.PISCES_EX,
    Astro.Collectible.GEMINI_EX,
    Astro.Collectible.PROMETHEUS,
    Astro.Collectible.PLATINUM_BULLET,
    Astro.Collectible.PTOLEMAEUS,
    Astro.Collectible.ALTAIR,
    Astro.Collectible.VEGA,
    Astro.Collectible.DIVINE_LIGHT,
    Astro.Collectible.ACUTE_SINUSITIS,
    Astro.Collectible.LANIAKEA_SUPERCLUSTER,
    Astro.Collectible.GALACTIC_MEDAL_OF_VALOR,
    Astro.Collectible.QUASAR,
    Astro.Collectible.FALLEN_ORB,
    Astro.Collectible.TRINITY,
    Astro.Collectible.CHAOS_DICE,
    Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS,
    Astro.Collectible.SAGITTARIUS_EX,
    Astro.Collectible.CHUBBY_HEAD,
    Astro.Collectible.SLEEPING_PUPPY,
    Astro.Collectible.CHUBBY_TAIL,
    Astro.Collectible.HAPPY_ONION,
    Astro.Collectible.KEY_IS_POWER,
    Astro.Collectible.BOMB_IS_POWER,
    Astro.Collectible.RHONGOMYNIAD,
    Astro.Collectible.ARTIFACT_SANCTUM,
    Astro.Collectible.AMPLIFYING_MIND,
    Astro.Collectible.HEART_BLOOM,
    Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE,
    Astro.Collectible.ABSOLUT_GUPPY,
    Astro.Collectible.DELIRIUM_GUPPY,
    Astro.Collectible.BIRTHRIGHT_THE_LOST,
    Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE,
    Astro.Collectible.RITE_OF_ARAMESIR,
    Astro.Collectible.TECHNOLOGY_OMICRON_EX,
    Astro.Collectible.AMAZING_CHAOS_SCROLL,
    Astro.Collectible.CURSE_OF_ARAMATIR,
    Astro.Collectible.CAINS_SECRET_BAG,
    Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL,
    Astro.Collectible.SACRED_DICE,
    Astro.Collectible.AMAZING_CHAOS_SCROLL_OF_GOODNESS,
    Astro.Collectible.COPERNICUS,
    Astro.Collectible.SUPER_NOVA,
    Astro.Collectible.SINFUL_SPOILS_STRUGGLE,
    Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN,
    Astro.Collectible.ABORTION,
    Astro.Collectible.ENTOMA_VASILISSA_ZETA,
    Astro.Collectible.BIRTHRIGHT_TAINTED_LOST
}

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.FALSE_CERTIFICATE,
        "위조증명서",
        "...",
        "사용 시 특정 아이템이 존재하는 방으로 이동합니다."
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

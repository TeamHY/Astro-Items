Astro.Collectible.FALSE_CERTIFICATE = Isaac.GetItemIdByName("False Certificate")

local FALSE_CERTIFICATE_ITEMS = {}
local FIGHT_BAN = {}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.FALSE_CERTIFICATE,
                "위조 증명서",
                "공문서 위조는 중범죄입니다",
                "{{UltraSecretRoom}} 사용 시 특급비밀방 배열 아이템이 있는 방으로 이동합니다." ..
                "#{{ArrowGrayRight}} 아이템 하나 획득 시 원래 있던 장소로 돌아갑니다."
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.FALSE_CERTIFICATE,
                "False Certificate",
                "",
                "{{UltraSecretRoom}} Teleports Isaac to a floor that contains every item of ultra secret room pool in the game" ..
                "#Choosing an item from this floor teleports Isaac back to the room he came from",
                nil, "en_us"
            )
        end

        FALSE_CERTIFICATE_ITEMS = {
            --CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM, --12
            CollectibleType.COLLECTIBLE_VIRUS, --13
            CollectibleType.COLLECTIBLE_HEART, --15
            CollectibleType.COLLECTIBLE_MOMS_HEELS, --30
            CollectibleType.COLLECTIBLE_MOMS_LIPSTICK, --31
            CollectibleType.COLLECTIBLE_KAMIKAZE, --40
            CollectibleType.COLLECTIBLE_YUM_HEART, --45
            CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP, --49
            CollectibleType.COLLECTIBLE_PENTAGRAM, --51
            CollectibleType.COLLECTIBLE_MAGNETO, --53
            CollectibleType.COLLECTIBLE_SISTER_MAGGY, --67
            CollectibleType.COLLECTIBLE_ROSARY, --72
            CollectibleType.COLLECTIBLE_CUBE_OF_MEAT, --73
            CollectibleType.COLLECTIBLE_MARK, --79
            CollectibleType.COLLECTIBLE_PACT, --80
            CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT, --82
            CollectibleType.COLLECTIBLE_LITTLE_CHAD, --96
            CollectibleType.COLLECTIBLE_D6, --105
            CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER, --109
            CollectibleType.COLLECTIBLE_MOMS_CONTACTS, --110
            CollectibleType.COLLECTIBLE_BRIMSTONE, --118
            CollectibleType.COLLECTIBLE_BLOOD_BAG, --119
            CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, --122
            CollectibleType.COLLECTIBLE_IV_BAG, --135
            CollectibleType.COLLECTIBLE_REMOTE_DETONATOR, --137
            CollectibleType.COLLECTIBLE_BLOODY_LUST, --157
            CollectibleType.COLLECTIBLE_SPIRIT_NIGHT, -- 159
            CollectibleType.COLLECTIBLE_D20, --166
            CollectibleType.COLLECTIBLE_HARLEQUIN_BABY, --167
            CollectibleType.COLLECTIBLE_STEM_CELLS, --176
            CollectibleType.COLLECTIBLE_PORTABLE_SLOT, --177
            --CollectibleType.COLLECTIBLE_SACRED_HEART, --182
            CollectibleType.COLLECTIBLE_MEAT, --193
            CollectibleType.COLLECTIBLE_CHAMPION_BELT, --208
            CollectibleType.COLLECTIBLE_ANEMIC, --214
            CollectibleType.COLLECTIBLE_ABADDON, --230
            CollectibleType.COLLECTIBLE_BFFS, --247
            CollectibleType.COLLECTIBLE_MAGIC_SCAB, --253
            CollectibleType.COLLECTIBLE_BLOOD_CLOT, --254
            --CollectibleType.COLLECTIBLE_PROPTOSIS, --261
            CollectibleType.COLLECTIBLE_ISAACS_HEART, --276
            CollectibleType.COLLECTIBLE_RED_CANDLE, --289
            CollectibleType.COLLECTIBLE_BODY, --334
            --CollectibleType.COLLECTIBLE_DEAD_EYE, --373
            CollectibleType.COLLECTIBLE_MARKED, --394
            CollectibleType.COLLECTIBLE_MAW_OF_VOID, --399
            CollectibleType.COLLECTIBLE_LUSTY_BLOOD, --411
            CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION, --412
            CollectibleType.COLLECTIBLE_KIDNEY_BEAN, --421
            CollectibleType.COLLECTIBLE_LIL_LOKI, --435
            --CollectibleType.COLLECTIBLE_APPLE, --443
            CollectibleType.COLLECTIBLE_VARICOSE_VEINS, --452
            --CollectibleType.COLLECTIBLE_EYE_OF_BELIAL, --462
            CollectibleType.COLLECTIBLE_CONTAGION, --466
            CollectibleType.COLLECTIBLE_PLAN_C, --475
            CollectibleType.COLLECTIBLE_DATAMINER, --481
            CollectibleType.COLLECTIBLE_BACKSTABBER, --506
            CollectibleType.COLLECTIBLE_ANGRY_FLY, --511
            --CollectibleType.COLLECTIBLE_HAEMOLACRIA, --531
            CollectibleType.COLLECTIBLE_MARROW, --541
            CollectibleType.COLLECTIBLE_2SPOOKY, --554
            CollectibleType.COLLECTIBLE_SULFUR, --556
            CollectibleType.COLLECTIBLE_BLOOD_PUPPY, --565
            CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT, --572
            CollectibleType.COLLECTIBLE_IMMACULATE_HEART, --573
            CollectibleType.COLLECTIBLE_RED_KEY, --580
            CollectibleType.COLLECTIBLE_OCULAR_RIFT, --606
            CollectibleType.COLLECTIBLE_BOILED_BABY, --607
            CollectibleType.COLLECTIBLE_BLOOD_BOMBS, --614
            CollectibleType.COLLECTIBLE_BIRDS_EYE, --616
            CollectibleType.COLLECTIBLE_ROTTEN_TOMATO, --618
            CollectibleType.COLLECTIBLE_RED_STEW, --621
            CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, --637
            CollectibleType.COLLECTIBLE_PLUM_FLUTE, --650
            CollectibleType.COLLECTIBLE_FALSE_PHD, --654
            CollectibleType.COLLECTIBLE_VASCULITIS, --657
            CollectibleType.COLLECTIBLE_CANDY_HEART, --671
            --CollectibleType.COLLECTIBLE_C_SECTION, 678
            CollectibleType.COLLECTIBLE_WORM_FRIEND, --682
            CollectibleType.COLLECTIBLE_HUNGRY_SOUL, --684
            CollectibleType.COLLECTIBLE_SANGUINE_BOND, --692
            CollectibleType.COLLECTIBLE_HEARTBREAK, --694
            CollectibleType.COLLECTIBLE_BLOODY_GUST, --695
            CollectibleType.COLLECTIBLE_ECHO_CHAMBER, --700
            CollectibleType.COLLECTIBLE_VENGEFUL_SPIRIT, --702
            CollectibleType.COLLECTIBLE_ESAU_JR, --703
            CollectibleType.COLLECTIBLE_BERSERK, --704
            CollectibleType.COLLECTIBLE_DARK_ARTS, --705
            CollectibleType.COLLECTIBLE_ABYSS, --706
            CollectibleType.COLLECTIBLE_FLIP, --711
            CollectibleType.COLLECTIBLE_HYPERCOAGULATION, --724
            CollectibleType.COLLECTIBLE_HEMOPTYSIS, --726
            CollectibleType.COLLECTIBLE_GELLO, --728
            ----
            Astro.Collectible.AMAZING_CHAOS_SCROLL,
            Astro.Collectible.AMPLIFYING_MIND,
            Astro.Collectible.ANGRY_ONION,
            Astro.Collectible.BIRTHRIGHT_APOLLYON_B,
            Astro.Collectible.BIRTHRIGHT_EVE,
            Astro.Collectible.BIRTHRIGHT_JUDAS,
            Astro.Collectible.BLOOD_OF_HATRED,
            Astro.Collectible.BLOOD_TRAIL,
            Astro.Collectible.BOMB_IS_POWER,
            Astro.Collectible.CALM_MIND,
            Astro.Collectible.CURSED_HEART,
            Astro.Collectible.FALLEN_ORB,
            Astro.Collectible.GALACTIC_MEDAL_OF_VALOR,
            Astro.Collectible.FORBIDDEN_DICE,
            Astro.Collectible.KEY_IS_POWER,
            Astro.Collectible.LOVE_LETTER,
            Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE,
            Astro.Collectible.PINK_WARD,
            Astro.Collectible.RED_CUBE,
            Astro.Collectible.RESTOCK_DICE,
            Astro.Collectible.RETROGRADE_ARCANA,
            Astro.Collectible.RGB,
            Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE,
            Astro.Collectible.SNAKE_EYES_POPLAR,
            Astro.Collectible.STRAWBERRY_MILK,
            Astro.Collectible.UNHOLY_MANTLE,
            Astro.Collectible.TECHRAPOD,
            Astro.Collectible.THROW_BOMB,
            Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL,
            Astro.Collectible.URINARY_INCONTINENCE,
            Astro.Collectible.ZOLTRAAK,
        }

        FIGHT_BAN = {
            CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM, --12
            CollectibleType.COLLECTIBLE_SACRED_HEART, --182
            CollectibleType.COLLECTIBLE_PROPTOSIS, --261
            CollectibleType.COLLECTIBLE_DEAD_EYE, --373
            CollectibleType.COLLECTIBLE_APPLE, --443
            CollectibleType.COLLECTIBLE_EYE_OF_BELIAL, --462
            CollectibleType.COLLECTIBLE_HAEMOLACRIA, --531
            CollectibleType.COLLECTIBLE_C_SECTION, --678
            ----
            Astro.Collectible.BLOOD_GUPPY,
            Astro.Collectible.DEATHS_EYES,
            Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS,
            Astro.Collectible.ENTOMA_VASILISSA_ZETA,
            Astro.Collectible.FORBIDDEN_DICE,
            Astro.Collectible.LEGACY,
            Astro.Collectible.MEGA_D6,
            Astro.Collectible.PURE_LOVE,
            Astro.Collectible.RESTOCK_DICE,
            Astro.Collectible.STAIRWAY_TO_HELL,
        }

        if not Astro.IsFight then
            for i = 1, #FIGHT_BAN do
                table.insert(FALSE_CERTIFICATE_ITEMS, FIGHT_BAN[i])
            end
        end
    end
)

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

Astro.Collectible.GENE_SCISSORS = Isaac.GetItemIdByName("Gene Scissors")

local ITEM_ID = Astro.Collectible.GENE_SCISSORS

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "유전자 가위",
                "",
                "사용 시 그 방의 선택형 아이템/픽업을 모두 획득할 수 있게 됩니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Gene Scissors", "",
                "Removes the choice restriction from all pickups in the room",
                nil, "en_us"
            )
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
        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            entity:ToPickup().OptionsPickupIndex = 0
        end

        SFXManager():Play(SoundEffect.SOUND_BLOODBANK_SPAWN)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    ITEM_ID
)

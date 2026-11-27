Astro.Collectible.MOLTEN_CORE = Isaac.GetItemIdByName("Molten Core")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.MOLTEN_CORE,
                "초고열 용광로",
                "",
                "사용 시 소지중인 장신구를 흡수해 효과를 영구적으로 얻습니다." ..
                "#흡수된 장신구는 {{ColorGold}}황금 형태로 흡수됩니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.MOLTEN_CORE,
                "Molten Core", "",
                "{{Trinket}} Consumes Isaac's held trinkets and grants its {{ColorGold}}golden{{CR}} effects permanently",
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
        for _ = 1, 2 do
            local trinket = playerWhoUsedItem:GetTrinket(0)
            
            if trinket ~= 0 then
                playerWhoUsedItem:TryRemoveTrinket(trinket)
                Astro:SmeltTrinket(playerWhoUsedItem, trinket | TrinketType.TRINKET_GOLDEN_FLAG)
            end
        end

        if SoundEffect.SOUND_SMELTER then
            SFXManager():Play(SoundEffect.SOUND_SMELTER)
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.MOLTEN_CORE
)

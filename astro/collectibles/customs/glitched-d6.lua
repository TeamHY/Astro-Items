Astro.Collectible.GLITCHED_D6 = Isaac.GetItemIdByName("Glitched D6")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.GLITCHED_D6,
        "글리치드 6각 주사위",
        "따따따따따따따따따따",
        "사용 시 {{Card41}}Soul of Isaac를 4번 발동합니다."
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
        for _ = 1, 4 do
            playerWhoUsedItem:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.GLITCHED_D6
) 

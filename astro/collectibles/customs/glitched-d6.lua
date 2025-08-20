Astro.Collectible.GLITCHED_D6 = Isaac.GetItemIdByName("Glitched D6")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.GLITCHED_D6,
        "글리치 주사위",
        "운운명명을을 굴굴려려라라라라...",
        "{{Collectible689}} 사용 시 그 방의 아이템이 4개의 랜덤 아이템과 0.2초마다 전환되어 5개의 아이템 중 하나를 선택할 수 있습니다."
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

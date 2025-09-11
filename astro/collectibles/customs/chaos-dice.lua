Astro.Collectible.CHAOS_DICE = Isaac.GetItemIdByName("Chaos Dice")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.CHAOS_DICE,
        "혼돈의 주사위",
        "혼돈이다, 혼돈이야!",
        "사용 시 그 방의 아이템과 픽업을 다른 아이템으로 바꿉니다."..
        "#{{ArrowGrayRight}} 바뀐 아이템의 배열은 랜덤으로 결정됩니다."
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
        playerWhoUsedItem:UseCard(Card.CARD_SOUL_EDEN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

        return true
    end,
    Astro.Collectible.CHAOS_DICE
)

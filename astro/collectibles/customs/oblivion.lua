Astro.Collectible.Oblivion = Isaac.GetItemIdByName("Oblivion")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.Oblivion,
        "망각",
        "흡수?",
        "{{Card41}} 그 방의 아이템을 흡수하고 흡수한 만큼 랜덤 능력치가 2개씩 증가합니다." ..
        "#{{Card41}} 그 방의 픽업을 흡수하고 흡수한 개수만큼 파란 아군 파리 및 거미를 소환합니다." ..
        "#{{Collectible35}} 그 방의 적에게 40의 피해를 줍니다."
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
        playerWhoUsedItem:UseCard(Card.RUNE_BLACK, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        return true
    end,
    Astro.Collectible.Oblivion
)

Astro.Collectible.Oblivion = Isaac.GetItemIdByName("Oblivion")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.Oblivion,
                "망각",
                "무의식 속으로",
                "{{Card41}} Black Rune 하나를 드랍합니다." ..
                "#!!! 사용 시:" ..
                "#{{ArrowGrayRight}} 그 방의 아이템을 흡수하고 흡수한 만큼 랜덤 능력치가 2개씩 증가합니다." ..
                "#{{ArrowGrayRight}} 그 방의 픽업을 흡수하고 흡수한 개수만큼 파란 아군 거미 및 파리를 소환합니다." ..
                "#{{ArrowGrayRight}} {{Collectible35}}그 방의 적에게 40의 피해를 줍니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.Oblivion,
                "Oblivion", "",
                "{{Card41}} Spawns a Black Rune on pickup" ..
                "#Upon use:" ..
                "#↑ Converts all pedestal items in the room into random stat ups" ..
                "#Converts all pickups in the room into blue flies" ..
                "#{{Collectible35}} Deals 40 damage to all enemies",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.Oblivion) then
            Astro:SpawnCard(Card.RUNE_BLACK, player.Position)
        end
    end,
    Astro.Collectible.Oblivion
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
        playerWhoUsedItem:UseCard(Card.RUNE_BLACK, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        return true
    end,
    Astro.Collectible.Oblivion
)

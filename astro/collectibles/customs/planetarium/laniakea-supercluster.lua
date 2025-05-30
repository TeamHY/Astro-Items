Astro.Collectible.LANIAKEA_SUPERCLUSTER = Isaac.GetItemIdByName("Laniakea Supercluster")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.LANIAKEA_SUPERCLUSTER, "라니아케아 초은하단", "...", "!!! 일회용#사용 시 {{Planetarium}}천체관 아이템이 존재하는 방으로 이동합니다.")
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
        Isaac.ExecuteCommand("goto s.planetarium.0")

        Astro:ScheduleForUpdate(
            function()
                playerWhoUsedItem:UseCard(Card.CARD_SOUL_ISAAC)
                playerWhoUsedItem:UseCard(Card.CARD_SOUL_ISAAC)
                playerWhoUsedItem:UseCard(Card.CARD_SOUL_ISAAC)

                Astro:SpawnTrinket(TrinketType.TRINKET_TELESCOPE_LENS, playerWhoUsedItem.Position)
            end,
            1
        )

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.LANIAKEA_SUPERCLUSTER
)

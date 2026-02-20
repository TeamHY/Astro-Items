Astro.Collectible.DADS_BOX = Isaac.GetItemIdByName("Dad's Box")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.DADS_BOX,
                "아빠의 상자",
                "뭐가 들었지...",
                "사용 시 랜덤 황금 장신구를 1개 드랍합니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.DADS_BOX,
                "Dad's Box", "",
                "Spawns 1 random golden trinket",
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
        local itemPool = Game():GetItemPool()
        local trinket = itemPool:GetTrinket()

        Astro:SpawnTrinket(trinket + 32768, playerWhoUsedItem.Position)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.DADS_BOX
)

AstroItems.Collectible.DADS_BOX = Isaac.GetItemIdByName("Dad's Box")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.DADS_BOX,
        "아빠의 상자",
        "...",
        "사용 시 황금 장신구 1개를 소환합니다."
    )
end

AstroItems:AddCallback(
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

        AstroItems:SpawnTrinket(trinket + 32768, playerWhoUsedItem.Position)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.DADS_BOX
)

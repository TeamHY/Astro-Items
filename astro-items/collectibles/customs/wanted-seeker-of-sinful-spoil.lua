AstroItems.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL = Isaac.GetItemIdByName("WANTED: Seeker of Sinful Spoil")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL,
        "죄보사냥의 악마",
        "...",
        "사용 시 현재 캐릭터가 디아벨스타가 됩니다."
        .. "#!!! 일회용 아이템"
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
        playerWhoUsedItem:ChangePlayerType(AstroItems.Players.DIABELLSTAR)

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL
)

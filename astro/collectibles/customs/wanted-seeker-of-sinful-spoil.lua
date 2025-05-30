Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL = Isaac.GetItemIdByName("WANTED: Seeker of Sinful Spoil")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL,
        "죄보사냥의 악마",
        "...",
        "!!! 일회용#사용 시 캐릭터를 디아벨스타로 변경합니다."
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
        playerWhoUsedItem:ChangePlayerType(Astro.Players.DIABELLSTAR)

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL
)

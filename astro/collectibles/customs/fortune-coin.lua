Astro.Collectible.FORTUNE_COIN = Isaac.GetItemIdByName("Fortune Coin")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.FORTUNE_COIN, "포츈 코인", "...", "!!! 일회용#사용 시 30% 확률(행운 1 = 1%p 증가)로 현재 방 배열 아이템이 소환됩니다.#실패 시 {{BrokenHeart}} 소지 불가능 체력 +3")
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
        if rngObj:RandomFloat() < 0.3 then
            Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_NULL, playerWhoUsedItem.Position)
        else
            playerWhoUsedItem:AddBrokenHearts(3)
        end

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.FORTUNE_COIN
)

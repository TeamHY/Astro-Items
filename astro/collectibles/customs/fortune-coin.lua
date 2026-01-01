---

local SPAWN_CHANCE = 0.3

local LUCK_MULTIPLY = 1 / 100

---

Astro.Collectible.FORTUNE_COIN = Isaac.GetItemIdByName("Fortune Coin")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.FORTUNE_COIN, 
        "포츈 코인",
        "올인",
        "!!! 일회용" ..
        "#사용 시 30%의 확률로 그 방의 아이템을 소환합니다." ..
        "#{{ArrowGrayRight}} 실패 시 {{BrokenHeart}}소지 불가능 체력 +3" ..
        "#{{LuckSmall}} 행운 70 이상일 때 100% 확률 (행운 1당 +1%p)"
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
        if rngObj:RandomFloat() < (SPAWN_CHANCE + playerWhoUsedItem.Luck * LUCK_MULTIPLY) then
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

---

local SPAWN_CHANCE = 0.3

local LUCK_MULTIPLY = 1 / 100

---

Astro.Collectible.FORTUNE_COIN = Isaac.GetItemIdByName("Fortune Coin")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.FORTUNE_COIN, 
        "포츈 코인",
        "...",
        "!!! 일회용 아이템" ..
        "#사용 시 30% 확률로 현재 방 배열 아이템이 소환됩니다. 실패 시 {{BrokenHeart}} 깨진 하트 3개를 얻습니다." ..
        "#!!! {{LuckSmall}}행운 수치 비례: 행운 70 이상일 때 100% 확률 (행운 1당 +1%p)"
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

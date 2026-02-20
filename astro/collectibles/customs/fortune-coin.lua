---

local SPAWN_CHANCE = 0.3

local LUCK_MULTIPLY = 1 / 100

local ADD_BROKEN_HEARTS = 3

---

Astro.Collectible.FORTUNE_COIN = Isaac.GetItemIdByName("Fortune Coin")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.FORTUNE_COIN, 
                "포츈 코인",
                "올인",
                "!!! 일회용 !!!" ..
                "#사용 시 " .. string.format("%.f", SPAWN_CHANCE * 100) .. "%의 확률로 그 방의 아이템을 소환합니다." ..
                "#{{ArrowGrayRight}} 실패 시 {{BrokenHeart}}부서진하트 +" .. string.format("%.f", ADD_BROKEN_HEARTS) ..
                "#{{LuckSmall}} 행운 70 이상일 때 100% 확률 (행운 1당 +1%p)"
            )
            
            Astro.EID:AddCollectible(
                Astro.Collectible.FORTUNE_COIN, 
                "Fortune Coin", "",
                "!!! SINGLE USE !!!" ..
                "#" .. string.format("%.f", SPAWN_CHANCE * 100) .. "% chance to spawn a random item from the current room's item pool (+1%p per Luck)" ..
                "#{{ArrowGrayRight}} Failure: +" .. string.format("%.f", ADD_BROKEN_HEARTS) .. " {{BrokenHeart}} Broken Hearts",
				nil, "en_us"
            )

            Astro.EID.LuckFormulas["5.100." .. tostring(Astro.Collectible.DIVINE_LIGHT)] = function(luck, num)
                return (SPAWN_CHANCE + luck * LUCK_MULTIPLY) * 100
            end
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
        if rngObj:RandomFloat() < (SPAWN_CHANCE + playerWhoUsedItem.Luck * LUCK_MULTIPLY) then
            Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_NULL, playerWhoUsedItem.Position)
        else
            playerWhoUsedItem:AddBrokenHearts(ADD_BROKEN_HEARTS)
        end

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.FORTUNE_COIN
)

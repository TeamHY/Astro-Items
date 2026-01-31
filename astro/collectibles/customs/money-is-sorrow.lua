---

local TEARS_INCREMENT = 0.1

---

Astro.Collectible.MONEY_IS_SADNESS = Isaac.GetItemIdByName("Money = Sorrow")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.MONEY_IS_SADNESS,
                "돈 = 슬픔",
                "돈으로는 행복을 살 수 없어",
                "{{TearsSmall}} 동전 1개당 연사 +0.1",
                -- 중첩 시
                "중첩 가능"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.MONEY_IS_SADNESS,
                "Money = Sorrow", "",
                "↑ {{Tears}} +0.1 Fire rate for every {{Coin}} coin Isaac has",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if not Astro.IsFight then
                    return {
                        reroll = selectedCollectible == Astro.Collectible.MONEY_IS_SADNESS,
                        modifierName = "Money = Sorrow"
                    }
                end
        
                return false
            end
        )
    end
)

local function DelayToTears(num)
    return 30 / (num + 1)
end
local function TearsToDelay(num)
    return (30 / num) - 1
end

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if not Astro.IsFight then return end

        local num = player:GetCollectibleNum(Astro.Collectible.MONEY_IS_SADNESS)

        if num > 0 then
            local increaseAmt = TEARS_INCREMENT * num
            local tearsToAdd = increaseAmt * player:GetNumCoins()
            player.MaxFireDelay = TearsToDelay(DelayToTears(player.MaxFireDelay) + tearsToAdd)
        end
    end,
    CacheFlag.CACHE_FIREDELAY
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function (_, player)
        if not Astro.IsFight then return end

        if player:HasCollectible(Astro.Collectible.MONEY_IS_SADNESS) then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end
)

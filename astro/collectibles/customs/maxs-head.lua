---

local DAMAGE_INCREMENT = 0.5

local DAMAGE_MULTIPLIER = 1.5

---

Astro.Collectible.MAXS_HEAD = Isaac.GetItemIdByName("Max's Head")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.MAXS_HEAD,
                "맥스의 머리",
                "공격력 증가",
                "!!! 소지중일 때 {{Collectible4}}Cricket's Head 미등장" ..
                "#↑ {{DamageSmall}}공격력 +0.5" ..
                "#↑ {{DamageSmall}}공격력 배율 x1.5",
                -- 중첩 시
                "중첩 시 공격력 배율이 중첩된 수만큼 곱 연산으로 적용"
            )
        end

        -- 맥스의 머리 소지 시 크리켓 머리 리롤 로직 추가
        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.MAXS_HEAD) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_CRICKETS_HEAD,
                        modifierName = "Max's Head"
                    }
                end
        
                return false
            end
        )
    end
)

-- 맥스의 머리 효과 적용
Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.MAXS_HEAD) and cacheFlag == CacheFlag.CACHE_DAMAGE then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.MAXS_HEAD)
            
            player.Damage = player.Damage + (DAMAGE_INCREMENT * itemCount)
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.MULTIPLY,
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.MAXS_HEAD) and cacheFlag == CacheFlag.CACHE_DAMAGE then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.MAXS_HEAD)

            player.Damage = player.Damage * (DAMAGE_MULTIPLIER ^ itemCount)
        end
    end
)

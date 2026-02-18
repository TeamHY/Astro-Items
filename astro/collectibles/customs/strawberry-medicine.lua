Astro.Collectible.STRAWBERRY_MEDICINE = Isaac.GetItemIdByName("Strawberry Medicine")

---

local DAMAGE_MULTI = 1.1

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.STRAWBERRY_MEDICINE,
                "딸기향 해열제",
                "찬란하게 빛나던 내 모습은 어디로 날아갔을까",
                "↑ {{DamageSmall}}공격력 배율 x" .. string.format("%.1f", DAMAGE_MULTI),
                -- 중첩 시
                "곱연산으로 중첩 가능"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.STRAWBERRY_MEDICINE,
                "Strawberry Medicine", "",
                "↑ {{Damage}} x" .. string.format("%.1f", DAMAGE_MULTI) .. " Damage multiplier",
                -- Stacks
                "Can Stacks",
                "en_us"
            )
        end
    end
)


Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.MULTIPLY,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function (_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.STRAWBERRY_MEDICINE) then
            local num = player:GetCollectibleNum(Astro.Collectible.STRAWBERRY_MEDICINE)

            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage * (DAMAGE_MULTI ^ num)
            end
        end
    end
)
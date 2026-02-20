Astro.Collectible.ANGRY_ONION = Isaac.GetItemIdByName("Angry Onion")

---

local TEARS_INCREASE = 0.7

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ANGRY_ONION,
                "화난 양파",
                "공격 속도 증가!",
                "↑ {{TearsSmall}} 연사(+상한) +0.7",
                -- 중첩 시
                "중첩 가능"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.ANGRY_ONION,
                "Angry Onion", "",
                "↑ {{Tears}} +0.7 Fire rate",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.ANGRY_ONION) then
            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, TEARS_INCREASE * player:GetCollectibleNum(Astro.Collectible.ANGRY_ONION))
            end
        end
    end
)

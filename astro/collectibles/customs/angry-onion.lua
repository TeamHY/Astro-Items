Astro.Collectible.ANGRY_ONION = Isaac.GetItemIdByName("Angry Onion")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.ANGRY_ONION, "화난 양파", "...", "↑ {{TearsSmall}}연사(고정) +0.7#중첩이 가능합니다.#캐릭터의 연사 배율과 상관 없이 항상 고정된 수치로 증가됩니다.")
end

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.ANGRY_ONION) then
            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, 0.7 * player:GetCollectibleNum(Astro.Collectible.ANGRY_ONION))
            end
        end
    end
)

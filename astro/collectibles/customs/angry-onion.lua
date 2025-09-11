Astro.Collectible.ANGRY_ONION = Isaac.GetItemIdByName("Angry Onion")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.ANGRY_ONION,
        "화난 양파",
        "공격 속도 증가!",
        "↑ {{TearsSmall}}최종 연사 +0.7",
        "(중첩 가능)"
    )
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

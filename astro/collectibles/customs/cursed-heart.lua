local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.CURSED_HEART = Isaac.GetItemIdByName("Cursed Heart")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.CURSED_HEART,
        "저주받은 심장",
        "유도 공격? + 공격력 증가",
        "#!!! 획득 이후 {{Collectible182}}Sacred Heart가 모든 배열에서 제거됨" ..
        "↑ {{DamageSmall}}공격력 배율 x1.25" ..
        "#공격이 50%의 확률로 적에게 유도됩니다." ..
        "#공격력 배율 중첩이 가능합니다."
    )
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Game():GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART)
    end,
    Astro.Collectible.CURSED_HEART
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.CURSED_HEART) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage * 1.25 ^ player:GetCollectibleNum(Astro.Collectible.CURSED_HEART)
            elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
            elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
                player.TearColor = Color(0.45, 0.3, 0.3)
            end
        end
    end
)

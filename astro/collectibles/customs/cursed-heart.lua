local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.CURSED_HEART = Isaac.GetItemIdByName("Cursed Heart")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.CURSED_HEART,
                "저주받은 심장",
                "유도 공격? + 공격력 증가",
                "↑ {{DamageSmall}}공격력 배율 x1.25" ..
                "#50% 확률로 공격에 유도 효과가 생깁니다.",
                -- 중첩 시
                "중첩 가등"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.CURSED_HEART,
                "Cursed Heart", "",
                "↑ {{Damage}} x1.25 Damage multiplier" ..
                "#50% chance to homing tear",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end
    end
)

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

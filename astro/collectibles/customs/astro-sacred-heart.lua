Astro.Collectible.ASTRO_SACRED_HEART = Isaac.GetItemIdByName("Astro Sacred Heart")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ASTRO_SACRED_HEART,
                "광휘로운 심장",
                "유도 공격 + 추가 피해",
                "↑ {{RangeSmall}}사거리 +3" ..
                "#공격에 유도 효과가 생깁니다." ..
                "#적이 받는 피해량이 2.3배로 증가합니다.",
                -- 중첩 시
                "중첩 시 적이 받는 피해량이 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.ASTRO_SACRED_HEART,
                "Astro Sacred Heart",
                "",
                "↑ {{Range}} +3 Range" ..
                "#Homing tears" ..
                "#{{Damage}} Damage to enemies increases by 2.3x on hit",
                -- Stacks
                "Stacks increase extra damage",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        if entity:IsVulnerableEnemy() and source.Entity ~= nil and damageFlags & DamageFlag.DAMAGE_IV_BAG == 0 then
            local player = Astro:GetPlayerFromEntity(source.Entity)
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.ASTRO_SACRED_HEART) then
                local numAstroSacredHeart = player:GetCollectibleNum(Astro.Collectible.ASTRO_SACRED_HEART)
                entity:TakeDamage(amount * ((2.3 * numAstroSacredHeart) - 1), damageFlags | DamageFlag.DAMAGE_IV_BAG, source, countdownFrames)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.ASTRO_SACRED_HEART) then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.ASTRO_SACRED_HEART)

            if cacheFlag == CacheFlag.CACHE_RANGE then
                player.TearRange = player.TearRange + (3 * 40)
            elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
            elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
                player.TearColor = Color(1.5, 2, 2)
            end
        end
    end
)
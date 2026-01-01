Astro.Collectible.PLATINUM_BULLET = Isaac.GetItemIdByName("Platinum Bullet")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.PLATINUM_BULLET,
        "백금 탄환",
        "백만 번 이상 사용됨",
        "방 클리어 시 {{DamageSmall}}공격력 및 {{TearsSmall}}연사 +0.02(고정)",
        -- 중첩 시
        "중첩 가능, 다음 증가량부터 적용"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data.PlatinumBulletStatus = 0
        else
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(Astro.Collectible.PLATINUM_BULLET) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function()
        local isRun = false

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.PLATINUM_BULLET) then
                if not isRun then
                    Astro.Data.PlatinumBulletStatus = Astro.Data.PlatinumBulletStatus + 0.02 * player:GetCollectibleNum(Astro.Collectible.PLATINUM_BULLET)

                    isRun = true
                end

                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.PLATINUM_BULLET) and Astro.Data.PlatinumBulletStatus ~= nil then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + Astro.Data.PlatinumBulletStatus
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, Astro.Data.PlatinumBulletStatus)
            end
        end
    end
)

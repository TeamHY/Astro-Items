AstroItems.Collectible.HAPPY_ONION = Isaac.GetItemIdByName("Happy Onion")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.HAPPY_ONION, "행복한 양파", "...", "방 클리어 시 공격력, 연사, 사거리, 속도, 행운 중 한 가지의 스텟이 0.7(고정) 증가됩니다.#스테이지 입장 시 증가된 스텟은 초기화되며, 최대 10번까지만 누적됩니다.#중첩 시 다음 증가량부터 적용됩니다.")
end

local HAPPY_ONION_INCREMENT = 0.7

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            AstroItems.Data.HappyOnion = {
                StageRoomClearCount = 0,
                Damage = 0,
                FireDelay = 0,
                Range = 0,
                Speed = 0,
                Luck = 0
            }
        else
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(AstroItems.Collectible.HAPPY_ONION) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:AddCacheFlags(CacheFlag.CACHE_RANGE)
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                    player:EvaluateItems()
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        AstroItems.Data.HappyOnion = {
            StageRoomClearCount = 0,
            Damage = 0,
            FireDelay = 0,
            Range = 0,
            Speed = 0,
            Luck = 0
        }

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.HAPPY_ONION) then
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:AddCacheFlags(CacheFlag.CACHE_RANGE)
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                player:EvaluateItems()
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function()
        local isRun = false

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if AstroItems.Data.HappyOnion ~= nil and player:HasCollectible(AstroItems.Collectible.HAPPY_ONION) then
                if not isRun then
                    AstroItems.Data.HappyOnion.StageRoomClearCount = AstroItems.Data.HappyOnion.StageRoomClearCount + 1

                    if AstroItems.Data.HappyOnion.StageRoomClearCount <= 10 then
                        local rng = player:GetCollectibleRNG(AstroItems.Collectible.HAPPY_ONION)
                        local random = rng:RandomInt(5)
                        local statusIncrement = HAPPY_ONION_INCREMENT * player:GetCollectibleNum(AstroItems.Collectible.HAPPY_ONION)

                        if random == 0 then
                            AstroItems.Data.HappyOnion.Damage = AstroItems.Data.HappyOnion.Damage + statusIncrement
                        elseif random == 1 then
                            AstroItems.Data.HappyOnion.FireDelay = AstroItems.Data.HappyOnion.FireDelay + statusIncrement
                        elseif random == 2 then
                            AstroItems.Data.HappyOnion.Range = AstroItems.Data.HappyOnion.Range + statusIncrement
                        elseif random == 3 then
                            AstroItems.Data.HappyOnion.Speed = AstroItems.Data.HappyOnion.Speed + statusIncrement
                        elseif random == 4 then
                            AstroItems.Data.HappyOnion.Luck = AstroItems.Data.HappyOnion.Luck + statusIncrement
                        end
                    end

                    isRun = true
                end

                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:AddCacheFlags(CacheFlag.CACHE_RANGE)
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                player:EvaluateItems()
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.HAPPY_ONION) and AstroItems.Data.HappyOnion ~= nil then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + AstroItems.Data.HappyOnion.Damage
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = AstroItems:AddTears(player.MaxFireDelay, AstroItems.Data.HappyOnion.FireDelay)
            elseif cacheFlag == CacheFlag.CACHE_RANGE then
                player.TearRange = player.TearRange + AstroItems.Data.HappyOnion.Range
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + AstroItems.Data.HappyOnion.Speed
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + AstroItems.Data.HappyOnion.Luck
            end
        end
    end
)


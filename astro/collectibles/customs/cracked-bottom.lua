---

local SPEED = 1

local FIRE_DELAY = 10

local DAMAGE = 3.5

local RANGE = 260

local SHOT_SPEED = 1

local LUCK = 0

---

Astro.Collectible.CRACKED_BOTTOM = Isaac.GetItemIdByName("Cracked Bottom")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.CRACKED_BOTTOM,
                "깨진 밑바닥",
                "이보다 밑은 없겠지",
                "{{Player0}} 능력치가 Isaac의 기본 능력치보다 낮아지지 않습니다."
            )
            EID:addCondition(
                "5.100.562",
                { "5.100.562", "5.350." .. tostring(Astro.Trinket.BLACK_MIRROR), "5.100.347", "5.100.485" },
                "다음 게임에서 {{Collectible" .. Astro.Collectible.CRACKED_BOTTOM .. "}} Cracked Bottom를 들고 시작합니다.",
                nil, "ko_kr", nil
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.CRACKED_BOTTOM,
                "Cracked Bottom",
                "",
                "↑ Prevents stats from being lowered to {{Player0}} Isaac's base for the rest of the run",
                nil, "en_us"
            )
            EID:addCondition(
                "5.100.562",
                { "5.100.562", "5.350." .. tostring(Astro.Trinket.BLACK_MIRROR), "5.100.347", "5.100.485" },
                "Grants {{Collectible" .. Astro.Collectible.CRACKED_BOTTOM .. "}} Cracked Bottom at the start of the next run",
                nil, "en_us", nil
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = Astro:GetPersistentPlayerData(player)

            if isContinued then
                if data.peakDamage then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            else
                Astro.Data.RunCrackedBottom = Astro.Data.RunCrackedBottom or false

                if not isContinued and Astro.Data.RunCrackedBottom then
                    player:AddCollectible(Astro.Collectible.CRACKED_BOTTOM)
                    Astro.Data.RunCrackedBottom = false
                end
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ROCK_BOTTOM) >= 2 then
            Astro.Data.RunCrackedBottom = true
        end
    end,
    CollectibleType.COLLECTIBLE_ROCK_BOTTOM
)

local function CheckHasRockBottom(player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM) then
        return true
    elseif player:HasCollectible(Astro.Collectible.POWER_ROCK_BOTTOM) then
        return true
    elseif player:HasCollectible(Astro.Collectible.RAPID_ROCK_BOTTOM) then
        return true
    elseif player:HasCollectible(Astro.Collectible.LUCKY_ROCK_BOTTOM) then
        return true
    end

    return false
end

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.ROCK_BOTTOM,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.CRACKED_BOTTOM) and not CheckHasRockBottom(player) then
            if cacheFlag == CacheFlag.CACHE_SPEED then
                if player.MoveSpeed < SPEED then
                    player.MoveSpeed = SPEED
                end
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                if player.MaxFireDelay > FIRE_DELAY then
                    player.MaxFireDelay = FIRE_DELAY
                end
            elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
                if player.Damage < DAMAGE then
                    player.Damage = DAMAGE
                end
            elseif cacheFlag == CacheFlag.CACHE_RANGE then
                if player.TearRange < RANGE then
                    player.TearRange = RANGE
                end
            elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
                if player.ShotSpeed < SHOT_SPEED then
                    player.ShotSpeed = SHOT_SPEED
                end
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                if player.Luck < LUCK then
                    player.Luck = LUCK
                end
            end
        end 
    end
)

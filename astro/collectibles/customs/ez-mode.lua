---

local SPEED_DECREMENT = -0.1

local TEARS_DECREMENT = -0.1

local DAMAGE_DECREMENT = -0.1

local RANGE_DECREMENT = -1

local SHOT_SPEED_DECREMENT = -0.1

local LUCK_DECREMENT = -1

---

Astro.Collectible.EZ_MODE = Isaac.GetItemIdByName("EZ Mode")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.EZ_MODE, "쉬운 모드", "...", "↓ {{LuckSmall}}행운 -9#후반 스테이지 진입 전까지 피격 페널티가 발생하지 않습니다. 대신 모든 스탯이 감소됩니다.#소울 하트 1개가 증가됩니다.")
end

Astro:AddCallback(
    Astro.Callbacks.PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.EZ_MODE) and not Astro:IsLatterStage() then
            local data = Astro:GetPersistentPlayerData(player)

            if not data["ezModeStatus"] then
                data["ezModeStatus"] = {
                    speed = 0,
                    tears = 0,
                    damage = 0,
                    range = 0,
                    shotSpeed = 0,
                    luck = 0
                }
            end

            data["ezModeStatus"].speed = data["ezModeStatus"].speed + SPEED_DECREMENT
            data["ezModeStatus"].tears = data["ezModeStatus"].tears + TEARS_DECREMENT
            data["ezModeStatus"].damage = data["ezModeStatus"].damage + DAMAGE_DECREMENT
            data["ezModeStatus"].range = data["ezModeStatus"].range + RANGE_DECREMENT
            data["ezModeStatus"].shotSpeed = data["ezModeStatus"].shotSpeed + SHOT_SPEED_DECREMENT
            data["ezModeStatus"].luck = data["ezModeStatus"].luck + LUCK_DECREMENT

            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()

            return false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.EZ_MODE) then
            local data = Astro:GetPersistentPlayerData(player)

            if data and data["ezModeStatus"] then
                if cacheFlag == CacheFlag.CACHE_SPEED then
                    player.MoveSpeed = player.MoveSpeed + data["ezModeStatus"].speed
                elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                    player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, data["ezModeStatus"].tears)
                elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
                    player.Damage = player.Damage + data["ezModeStatus"].damage
                elseif cacheFlag == CacheFlag.CACHE_RANGE then
                    player.TearRange = player.TearRange + data["ezModeStatus"].range
                elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
                    player.ShotSpeed = player.ShotSpeed + data["ezModeStatus"].shotSpeed
                elseif cacheFlag == CacheFlag.CACHE_LUCK then
                    player.Luck = player.Luck + data["ezModeStatus"].luck
                end
            end

            if cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck - 9
            end
        end
    end
)

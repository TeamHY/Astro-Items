---
local STEW_DURATION = 180 * 30 -- 3분

local DECREMENT_INTERVAL = 30

local BLUE_STEW_TEAR_INCREMENT = 0.12 -- 0.12 * 180 = 21.6

local GREEN_STEW_LUCK_INCREMENT = 0.12 -- 0.12 * 180 = 21.6

local BROWN_STEW_SPEED_INCREMENT = 0.006 -- 0.006 * 180 = 1.08
---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BLUE_STEW = Isaac.GetItemIdByName("Blue Stew")
Astro.Collectible.GREEN_STEW = Isaac.GetItemIdByName("Green Stew")
Astro.Collectible.BROWN_STEW = Isaac.GetItemIdByName("Brown Stew")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BLUE_STEW,
        "푸른 스튜",
        "...",
        -- "{{HealingRed}} 체력을 모두 회복합니다." .. 
        "↑ {{TearsSmall}}연사(고정) +21.6"..
        "#{{ArrowGrayRight}} 증가한 {{TearsSmall}}연사는 1초마다 -0.12" ..
        "#{{ArrowGrayRight}} 감소 중 적 처치 시 {{TearsSmall}}연사 +0.12"
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.GREEN_STEW,
        "초록 스튜",
        "...",
        -- "{{HealingRed}} 체력을 모두 회복합니다." .. 
        "↑ {{LuckSmall}}행운 +21.6"..
        "#{{ArrowGrayRight}} 증가한 {{LuckSmall}}행운은 1초마다 -0.12" ..
        "#{{ArrowGrayRight}} 감소 중 적 처치 시 {{LuckSmall}}행운 +0.12"
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.BROWN_STEW,
        "갈색 스튜",
        "...",
        -- "{{HealingRed}} 체력을 모두 회복합니다." .. 
        "↑ {{SpeedSmall}}이동속도 +1.08"..
        "#{{ArrowGrayRight}} 증가한 {{SpeedSmall}}이동속도는 1초마다 -0.006" ..
        "#{{ArrowGrayRight}} 감소 중 적 처치 시 {{SpeedSmall}}이동속도 +0.006"
    )
end

local BLUE_STEW_KEY = "blueStew"
local GREEN_STEW_KEY = "greenStew"
local BROWN_STEW_KEY = "brownStew"

local stewDataKey = {
    [Astro.Collectible.BLUE_STEW] = BLUE_STEW_KEY,
    [Astro.Collectible.GREEN_STEW] = GREEN_STEW_KEY,
    [Astro.Collectible.BROWN_STEW] = BROWN_STEW_KEY
}

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if stewDataKey[collectibleType] then
            local data = Astro:GetPersistentPlayerData(player)

            if data then
                data[stewDataKey[collectibleType]] = Game():GetFrameCount() + STEW_DURATION
            end

            if collectibleType == Astro.Collectible.BLUE_STEW then
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            elseif collectibleType == Astro.Collectible.GREEN_STEW then
                player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            elseif collectibleType == Astro.Collectible.BROWN_STEW then
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            end

            player:EvaluateItems()
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        if npc.Type ~= EntityType.ENTITY_FIREPLACE then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
                local data = Astro:GetPersistentPlayerData(player)
                local current = Game():GetFrameCount()

                for _, value in pairs(stewDataKey) do
                    if data[value] and data[value] > current then
                        data[value] = data[value] + DECREMENT_INTERVAL

                        if data[value] > current + STEW_DURATION then
                            data[value] = current + STEW_DURATION
                        end
                    end
                end

                if player:HasCollectible(Astro.Collectible.BLUE_STEW) then
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                elseif player:HasCollectible(Astro.Collectible.GREEN_STEW)then
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                elseif player:HasCollectible(Astro.Collectible.BROWN_STEW) then
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                end
    
                player:EvaluateItems()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if Game():GetFrameCount() % DECREMENT_INTERVAL == 0 then
            if player:HasCollectible(Astro.Collectible.BLUE_STEW) then
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            end

            if player:HasCollectible(Astro.Collectible.GREEN_STEW) then
                player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            end

            if player:HasCollectible(Astro.Collectible.BROWN_STEW) then
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            end

            player:EvaluateItems()
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data = Astro:GetPersistentPlayerData(player)

        if data then
            if cacheFlag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(Astro.Collectible.BLUE_STEW) then
                local duration = data[BLUE_STEW_KEY]
                local current = Game():GetFrameCount()

                if current < duration then
                    player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, (math.floor(duration - current) / DECREMENT_INTERVAL) * BLUE_STEW_TEAR_INCREMENT)
                end
            elseif cacheFlag == CacheFlag.CACHE_LUCK and player:HasCollectible(Astro.Collectible.GREEN_STEW) then
                local duration = data[GREEN_STEW_KEY]
                local current = Game():GetFrameCount()

                if current < duration then
                    player.Luck = player.Luck + math.floor((duration - current) / DECREMENT_INTERVAL) * GREEN_STEW_LUCK_INCREMENT
                end
            elseif cacheFlag == CacheFlag.CACHE_SPEED and player:HasCollectible(Astro.Collectible.BROWN_STEW) then
                local duration = data[BROWN_STEW_KEY]
                local current = Game():GetFrameCount()

                if current < duration then
                    player.MoveSpeed = player.MoveSpeed + math.floor((duration - current) / DECREMENT_INTERVAL) * BROWN_STEW_SPEED_INCREMENT
                end
            end
        end
    end
)

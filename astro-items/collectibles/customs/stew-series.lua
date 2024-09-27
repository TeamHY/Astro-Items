---
local STEW_DURATION = 180 * 30 -- 3분

local DECREMENT_INTERVAL = 30

local BLUE_STEW_TEAR_INCREMENT = 0.12 -- 0.12 * 180 = 21.6

local GREEN_STEW_LUCK_INCREMENT = 0.12 -- 0.12 * 180 = 21.6

local BROWN_STEW_SPEED_INCREMENT = 0.006 -- 0.006 * 180 = 1.08
---

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.BLUE_STEW = Isaac.GetItemIdByName("Blue Stew")
AstroItems.Collectible.GREEN_STEW = Isaac.GetItemIdByName("Green Stew")
AstroItems.Collectible.BROWN_STEW = Isaac.GetItemIdByName("Brown Stew")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.BLUE_STEW,
        "푸른 스튜",
        "...",
        -- "{{HealingRed}} 체력을 모두 회복합니다." .. 
        "{{TearsSmall}}연사(고정)가 +21.6 증가하며 증가한 연사는 1초마다 -0.12씩 감소합니다." ..
        "#연사 감소 중에 적 처치시 일시적으로 연사가 +0.12 증가합니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.GREEN_STEW,
        "초록 스튜",
        "...",
        -- "{{HealingRed}} 체력을 모두 회복합니다." .. 
        "{{LuckSmall}}행운이 +21.6 증가하며 증가한 행운은 1초마다 -0.12씩 감소합니다." ..
        "#행운 감소 중에 적 처치시 일시적으로 행운이 +0.12 증가합니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.BROWN_STEW,
        "갈색 스튜",
        "...",
        -- "{{HealingRed}} 체력을 모두 회복합니다." .. 
        "{{SpeedSmall}}이동 속도가 +1.08 증가하며 증가한 이동 속도는 1초마다 -0.006씩 감소합니다." ..
        "#이동 속도 감소 중에 적 처치시 일시적으로 이동 속도가 +0.006 증가합니다."
    )
end

local BLUE_STEW_KEY = "blueStew"
local GREEN_STEW_KEY = "greenStew"
local BROWN_STEW_KEY = "brownStew"

local stewDataKey = {
    [AstroItems.Collectible.BLUE_STEW] = BLUE_STEW_KEY,
    [AstroItems.Collectible.GREEN_STEW] = GREEN_STEW_KEY,
    [AstroItems.Collectible.BROWN_STEW] = BROWN_STEW_KEY
}

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if stewDataKey[collectibleType] then
            local data = AstroItems:GetPersistentPlayerData(player)

            if data then
                data[stewDataKey[collectibleType]] = Game():GetFrameCount() + STEW_DURATION
            end

            if collectibleType == AstroItems.Collectible.BLUE_STEW then
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            elseif collectibleType == AstroItems.Collectible.GREEN_STEW then
                player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            elseif collectibleType == AstroItems.Collectible.BROWN_STEW then
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            end

            player:EvaluateItems()
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        if npc.Type ~= EntityType.ENTITY_FIREPLACE then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
                local data = AstroItems:GetPersistentPlayerData(player)
                local current = Game():GetFrameCount()

                for _, value in pairs(stewDataKey) do
                    if data[value] and data[value] > current then
                        data[value] = data[value] + DECREMENT_INTERVAL

                        if data[value] > current + STEW_DURATION then
                            data[value] = current + STEW_DURATION
                        end
                    end
                end

                if player:HasCollectible(AstroItems.Collectible.BLUE_STEW) then
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                elseif player:HasCollectible(AstroItems.Collectible.GREEN_STEW)then
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                elseif player:HasCollectible(AstroItems.Collectible.BROWN_STEW) then
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                end
    
                player:EvaluateItems()
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if Game():GetFrameCount() % DECREMENT_INTERVAL == 0 then
            if player:HasCollectible(AstroItems.Collectible.BLUE_STEW) then
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            end

            if player:HasCollectible(AstroItems.Collectible.GREEN_STEW) then
                player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            end

            if player:HasCollectible(AstroItems.Collectible.BROWN_STEW) then
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            end

            player:EvaluateItems()
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data = AstroItems:GetPersistentPlayerData(player)

        if data then
            if cacheFlag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(AstroItems.Collectible.BLUE_STEW) then
                local duration = data[BLUE_STEW_KEY]
                local current = Game():GetFrameCount()

                if current < duration then
                    player.MaxFireDelay = AstroItems:AddTears(player.MaxFireDelay, (math.floor(duration - current) / DECREMENT_INTERVAL) * BLUE_STEW_TEAR_INCREMENT)
                end
            elseif cacheFlag == CacheFlag.CACHE_LUCK and player:HasCollectible(AstroItems.Collectible.GREEN_STEW) then
                local duration = data[GREEN_STEW_KEY]
                local current = Game():GetFrameCount()

                if current < duration then
                    player.Luck = player.Luck + math.floor((duration - current) / DECREMENT_INTERVAL) * GREEN_STEW_LUCK_INCREMENT
                end
            elseif cacheFlag == CacheFlag.CACHE_SPEED and player:HasCollectible(AstroItems.Collectible.BROWN_STEW) then
                local duration = data[BROWN_STEW_KEY]
                local current = Game():GetFrameCount()

                if current < duration then
                    player.MoveSpeed = player.MoveSpeed + math.floor((duration - current) / DECREMENT_INTERVAL) * BROWN_STEW_SPEED_INCREMENT
                end
            end
        end
    end
)

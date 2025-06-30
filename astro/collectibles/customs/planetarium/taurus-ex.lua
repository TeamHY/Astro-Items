Astro.Collectible.TAURUS_EX = Isaac.GetItemIdByName("Taurus EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.TAURUS_EX,
        "초 황소자리",
        "...",
        "{{BossRoom}} 보스방 입장 시 아래 효과들이 적용됩니다." ..
        "#{{ArrowGrayRight}} {{TearsSmall}}연사(상한) +2" ..
        "#{{ArrowGrayRight}} {{DamageSmall}}공격력 +2" ..
        "#{{ArrowGrayRight}} {{SpeedSmall}}이동속도를 최대치로 설정합니다.#{{Blank}} (이미 최대라면 미선택)" ..
        "#{{ArrowGrayRight}} {{RangeSmall}}사거리 +3#{{Blank}} 공격이 적에게 유도됩니다." ..
        "#중첩이 가능합니다."
    )
end

local effects = {
    ---@param player EntityPlayer
    [0] = function(player)
        for _ = 1, player:GetCollectibleNum(Astro.Collectible.TAURUS_EX) do
            player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, false, true, false, false)
        end
    end,
    ---@param player EntityPlayer
    [1] = function(player)
        for _ = 1, player:GetCollectibleNum(Astro.Collectible.TAURUS_EX) do
            player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK, false, true, false, false)
        end
    end,
    ---@param player EntityPlayer
    [2] = function(player)
    end,
    ---@param player EntityPlayer
    [3] = function(player)
    end
}

---@param player EntityPlayer
local function checkMaxSpeed(player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MERCURIUS) then
        if player.MoveSpeed >= 1.4 then
            return true
        end
    else
        if player.MoveSpeed >= 2 then
            return true
        end
    end

    return false
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        ---@type EntityPlayer
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.TAURUS_EX) then
                local data = player:GetData()

                if data.Taurus == nil then
                    data.Taurus = {
                        Key = -1
                    }
                end

                local room = Game():GetRoom()

                if room:GetType() == RoomType.ROOM_BOSS then
                    for j = 0, 3 do
                        if not (checkMaxSpeed(player) and j == 2) then
                            effects[j](player)
                        end
                    end
    
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:EvaluateItems()
    
                    goto continue
                end

                -- repeat
                --     data.Taurus.Key = player:GetCollectibleRNG(Astro.Collectible.TAURUS_EX):RandomInt(4)
                -- until not (checkMaxSpeed(player) and data.Taurus.Key == 2)

                -- effects[data.Taurus.Key](player)
                -- player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                -- player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                -- player:EvaluateItems()
            end

            ::continue::
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.TAURUS_EX) then
            local data = player:GetData()
            local room = Game():GetRoom()

            if data.Taurus ~= nil then
                if cacheFlag == CacheFlag.CACHE_SPEED and (data.Taurus.Key == 2 or room:GetType() == RoomType.ROOM_BOSS)then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_MERCURIUS) then
                        if player.MoveSpeed < 1.4 then
                            player.MoveSpeed = 1.4
                        end
                    else
                        if player.MoveSpeed < 2 then
                            player.MoveSpeed = 2
                        end
                    end
                elseif cacheFlag == CacheFlag.CACHE_FIREDELAY and (data.Taurus.Key == 3 or room:GetType() == RoomType.ROOM_BOSS) then
                    player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, 2 * player:GetCollectibleNum(Astro.Collectible.TAURUS_EX))
                end
            end
        end
    end
)

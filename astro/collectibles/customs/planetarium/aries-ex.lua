Astro.Collectible.ARIES_EX = Isaac.GetItemIdByName("Aries EX")

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ARIES_EX,
                "초 양자리",
                "실전 압축",
                "↑ {{SpeedSmall}}이동속도 +0.25" ..
                "#{{Collectible300}} 이동속도가 0.85 이상인 상태에서 높은 속도로 적과 접촉시 피해를 받지 않고 적에게 25의 피해를 줍니다." ..
                "#{{BossRoom}} 보스방 입장 시 아래 효과 중 하나 적용:" ..
                "#{{ArrowGrayRight}} {{TearsSmall}}연사(+상한) +2" ..
                "#{{ArrowGrayRight}} {{DamageSmall}}공격력 +2" ..
                "#{{ArrowGrayRight}} {{SpeedSmall}}이동속도(고정) +2#{{Blank}} (이미 2.0라면 건너뜀)" ..
                "#{{ArrowGrayRight}} {{Collectible192}} 공격이 적에게 유도되며 {{RangeSmall}}사거리가 3 증가합니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.ARIES_EX,
                "Aries EX", "",
                "↑ {{Speed}} +0.25 Speed" ..
                "#{{Collectible300}} Moving above 0.85 speed makes Isaac immune to contact damage and deals 25 damage to enemies" ..
                "#On entering {{BossRoom}} boss room, one of the following effects:" ..
                "#{{ArrowGrayRight}} {{Tears}} +2 Fire rate" ..
                "#{{ArrowGrayRight}} {{Damage}} +2 Damage" ..
                "#{{ArrowGrayRight}} {{Speed}} +2 Speed#{{Blank}} (Skips if already 2.0)" ..
                "#{{ArrowGrayRight}} {{Collectible192}} {{Range}} +3 Range and homing tears",
                nil, "en_us"
            )
        end
    end
)

------ 기존 초 황소자리 ------
local effects = {
    ---@param player EntityPlayer
    [0] = function(player)
        for _ = 1, player:GetCollectibleNum(Astro.Collectible.ARIES_EX) do
            player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, false, true, false, false)
        end
    end,
    ---@param player EntityPlayer
    [1] = function(player)
        for _ = 1, player:GetCollectibleNum(Astro.Collectible.ARIES_EX) do
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

            if player:HasCollectible(Astro.Collectible.ARIES_EX) then
                local data = player:GetData()

                if data._ASTRO_AriesEX == nil then
                    data._ASTRO_AriesEX = {
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
                --     data._ASTRO_AriesEX.Key = player:GetCollectibleRNG(Astro.Collectible.ARIES_EX):RandomInt(4)
                -- until not (checkMaxSpeed(player) and data._ASTRO_AriesEX.Key == 2)

                -- effects[data._ASTRO_AriesEX.Key](player)
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
        if player:HasCollectible(Astro.Collectible.ARIES_EX) then
            local data = player:GetData()
            local room = Game():GetRoom()

            if data._ASTRO_AriesEX ~= nil then
                if cacheFlag == CacheFlag.CACHE_SPEED and (data._ASTRO_AriesEX.Key == 2 or room:GetType() == RoomType.ROOM_BOSS)then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_MERCURIUS) then
                        if player.MoveSpeed < 1.4 then
                            player.MoveSpeed = 1.4
                        end
                    else
                        if player.MoveSpeed < 2 then
                            player.MoveSpeed = 2
                        end
                    end
                elseif cacheFlag == CacheFlag.CACHE_FIREDELAY and (data._ASTRO_AriesEX.Key == 3 or room:GetType() == RoomType.ROOM_BOSS) then
                    player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, 2 * player:GetCollectibleNum(Astro.Collectible.ARIES_EX))
                end
            end
        end
    end
)


------ 히든 아이템 ------
Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_ARIES)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_ARIES) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_ARIES)
        end

        local ic = Isaac.GetItemConfig()
        player:RemoveCostume(ic:GetCollectible(CollectibleType.COLLECTIBLE_ARIES))
    end,
    Astro.Collectible.ARIES_EX
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_ARIES) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_ARIES)
        end
    end,
    Astro.Collectible.ARIES_EX
)

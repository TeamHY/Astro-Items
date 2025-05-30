---

local WATER_ENCHANTRESS_MULTIPLIER = 1.1

local MAX_COUNT = 2

local WATER_ENCHANTRESS_MAX_COUNT = 5

---

Astro.Collectible.DRACOBACK = Isaac.GetItemIdByName("Dracoback, the Rideable Dragon")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.DRACOBACK,
        "기룡 드라코백",
        "...",
        "방 입장 시 적 하나가 지워집니다."..
        "#{{BossRoom}}보스방에서는 발동하지 않습니다."..
        "#중첩 시 방 마다 지워지는 적의 수가 증가합니다."..
        "#스테이지마다 최대 2회, 성전의 수견사와 일리걸 나이트는 최대 5회까지 발동됩니다."..
        "#성전의 수견사, 일리걸 나이트가 획득 시 모든 능력치 x1.1"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = Astro:GetPersistentPlayerData(player);

            if data then
                data["dracobackCount"] = 0
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            
            if not player:HasCollectible(Astro.Collectible.DRACOBACK) then
                goto continue
            end
            
            local data = Astro:GetPersistentPlayerData(player);

            if not data["dracobackCount"] then
                data["dracobackCount"] = 0
            end

            if Astro:IsWaterEnchantress(player) then
                if data["dracobackCount"] >= WATER_ENCHANTRESS_MAX_COUNT then
                    goto continue
                end
            elseif data["dracobackCount"] >= MAX_COUNT then
                goto continue
            end
            
            local room = Game():GetRoom();

            if not room:IsClear() and room:GetType() ~= RoomType.ROOM_BOSS then
                local entities = Astro:Filter(Isaac.GetRoomEntities(), function(entity)
                    return entity:IsVulnerableEnemy() and not entity:IsBoss() and entity.Type ~= EntityType.ENTITY_FIREPLACE
                end)

                if #entities > 0 then
                    data["dracobackCount"] = data["dracobackCount"] + 1
                end

                local rng = player:GetCollectibleRNG(Astro.Collectible.DRACOBACK)
                local dracobackNum = player:GetCollectibleNum(Astro.Collectible.DRACOBACK)

                for _ = 1, math.min(#entities, dracobackNum) do
                    local index = rng:RandomInt(#entities) + 1
                    local entity = entities[index]

                    Isaac.Spawn(
                        EntityType.ENTITY_TEAR,
                        TearVariant.ERASER,
                        0,
                        entity.Position,
                        Vector.Zero,
                        player
                    )

                    table.remove(entities, index)
                end
            end

            ::continue::
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.MULTIPLY,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function (_, player, cacheFlag)
        if not player:HasCollectible(Astro.Collectible.DRACOBACK) then return end

        if not Astro:IsWaterEnchantress(player) then return end

        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = ((player.MaxFireDelay + 1) / WATER_ENCHANTRESS_MULTIPLIER) - 1
        end

        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * WATER_ENCHANTRESS_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed * WATER_ENCHANTRESS_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_LUCK and player.Luck > 0 then
            player.Luck = player.Luck * WATER_ENCHANTRESS_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * WATER_ENCHANTRESS_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed * WATER_ENCHANTRESS_MULTIPLIER
        end
    end
)

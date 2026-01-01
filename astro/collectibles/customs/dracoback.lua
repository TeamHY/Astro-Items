---

local WATER_ENCHANTRESS_MULTIPLIER = 1.1

local MAX_COUNT = 2

local WATER_ENCHANTRESS_MAX_COUNT = 5

---

Astro.Collectible.DRACOBACK = Isaac.GetItemIdByName("Dracoback, the Rideable Dragon")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.DRACOBACK,
                "기룡 드라코백",
                "호감패",
                "{{Collectible638}} {{ColorOrange}}보스방을 제외한{{CR}} 방 입장 시 스테이지 당 최대 ".. MAX_COUNT .. "번 랜덤 적 하나가 지워집니다.",
                -- 중첩 시
                "중첩된 수만큼 적을 지우려 시도"
            )
            Astro.EID:AddCollectible(
                Astro.Collectible.DRACOBACK,
                "Dracoback, the Rideable Dragon",
                "",
                "{{Collectible638}} {{ColorOrange}}Excluding boss rooms{{CR}}, erases one random enemy max ".. MAX_COUNT .. " per stage on room entry",
                -- Stacks
                "Attempt to eliminate enemies equal to the number stacked",
                "en_us"
            )
            Astro.EID:RegisterAlternativeText(
                { itemType = ItemType.ITEM_PASSIVE, subType = Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL },
                "Dracoback",
                "The rideable dragon"
            )

            -- 캐릭터 시너지
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.DRACOBACK),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                {
                    "최대 ".. MAX_COUNT .. "번",
                    "최대 {{ColorIsaac}}".. WATER_ENCHANTRESS_MAX_COUNT .. "{{CR}}번"
                },
                nil, "ko_kr", nil
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.DRACOBACK),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                "{{DamageSmall}}공격력, ¤¤{{TearsSmall}}연사, {{RangeSmall}}사거리, {{SpeedSmall}}이동속도, {{ShotspeedSmall}}탄속, {{LuckSmall}}행운이 " .. WATER_ENCHANTRESS_MULTIPLIER .. "배 증가합니다.",
                nil, "ko_kr", nil
            )
            
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.DRACOBACK),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                {
                    "max ".. MAX_COUNT .. " per stage",
                    "max {{ColorIsaac}}".. WATER_ENCHANTRESS_MAX_COUNT .. "{{CR}} per stage"
                },
                nil, "en_us", nil
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.DRACOBACK),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                "Damage, Tears, Range, Speed, Shot speed, Luck increases by " .. WATER_ENCHANTRESS_MULTIPLIER .. "x",
                nil, "en_us", nil
            )
        end
    end
)

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

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            -- 깨끗한 침대방(세트룸)
            Astro.Data.IsaacPool = {
                --악마
                CollectibleType.COLLECTIBLE_PENTAGRAM,
                CollectibleType.COLLECTIBLE_MARK,
                CollectibleType.COLLECTIBLE_PACT,
                CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT,
                CollectibleType.COLLECTIBLE_BRIMSTONE,
                CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT,
                CollectibleType.COLLECTIBLE_ABADDON,
                CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID,
                CollectibleType.COLLECTIBLE_SULFUR,
                CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT,
                --천사
                CollectibleType.COLLECTIBLE_BIBLE,
                CollectibleType.COLLECTIBLE_ROSARY,
                CollectibleType.COLLECTIBLE_HALO,
                CollectibleType.COLLECTIBLE_SCAPULAR,
                CollectibleType.COLLECTIBLE_CELTIC_CROSS,
                CollectibleType.COLLECTIBLE_MITRE,
                CollectibleType.COLLECTIBLE_SACRED_HEART,
                CollectibleType.COLLECTIBLE_HOLY_GRAIL,
                CollectibleType.COLLECTIBLE_DEAD_DOVE,
                CollectibleType.COLLECTIBLE_HOLY_MANTLE,
                CollectibleType.COLLECTIBLE_GODHEAD,
                CollectibleType.COLLECTIBLE_HOLY_LIGHT,
                CollectibleType.COLLECTIBLE_DIVINE_INTERVENTION,
                CollectibleType.COLLECTIBLE_IMMACULATE_HEART,
                CollectibleType.COLLECTIBLE_REVELATION,
                CollectibleType.COLLECTIBLE_SACRED_ORB,
                CollectibleType.COLLECTIBLE_SALVATION,
                --구피
                CollectibleType.COLLECTIBLE_DEAD_CAT,
                CollectibleType.COLLECTIBLE_GUPPYS_PAW,
                CollectibleType.COLLECTIBLE_GUPPYS_TAIL,
                CollectibleType.COLLECTIBLE_GUPPYS_HEAD,
                CollectibleType.COLLECTIBLE_GUPPYS_HAIRBALL,
                CollectibleType.COLLECTIBLE_GUPPYS_COLLAR,
                CollectibleType.COLLECTIBLE_GUPPYS_EYE,
                --파리셋
                CollectibleType.COLLECTIBLE_SKATOLE,
                CollectibleType.COLLECTIBLE_HALO_OF_FLIES,
                CollectibleType.COLLECTIBLE_DISTANT_ADMIRATION,
                CollectibleType.COLLECTIBLE_FOREVER_ALONE,
                CollectibleType.COLLECTIBLE_MULLIGAN,
                CollectibleType.COLLECTIBLE_HIVE_MIND,
                CollectibleType.COLLECTIBLE_SMART_FLY,
                CollectibleType.COLLECTIBLE_BBF,
                CollectibleType.COLLECTIBLE_BEST_BUD,
                CollectibleType.COLLECTIBLE_BIG_FAN,
                CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND,
                CollectibleType.COLLECTIBLE_FRIEND_ZONE,
                CollectibleType.COLLECTIBLE_LOST_FLY,
                CollectibleType.COLLECTIBLE_OBSESSED_FAN,
                CollectibleType.COLLECTIBLE_PAPA_FLY,
                CollectibleType.COLLECTIBLE_JAR_OF_FLIES,
                CollectibleType.COLLECTIBLE_PARASITOID,
                CollectibleType.COLLECTIBLE_YO_LISTEN,
                CollectibleType.COLLECTIBLE_ANGRY_FLY,
                CollectibleType.COLLECTIBLE_PSY_FLY,
                CollectibleType.COLLECTIBLE_BOT_FLY,
                CollectibleType.COLLECTIBLE_FRUITY_PLUM,
                CollectibleType.COLLECTIBLE_PLUM_FLUTE,
                CollectibleType.COLLECTIBLE_SWARM
            }

            -- 더러운 침대방(클로버룸)
            Astro.Data.BarrenPool = {
                CollectibleType.COLLECTIBLE_MY_REFLECTION,
                CollectibleType.COLLECTIBLE_LUCKY_FOOT,
                CollectibleType.COLLECTIBLE_TOUGH_LOVE,
                CollectibleType.COLLECTIBLE_MAGIC_SCAB,
                CollectibleType.COLLECTIBLE_LATCH_KEY,
                CollectibleType.COLLECTIBLE_MOMS_PEARLS,
                CollectibleType.COLLECTIBLE_HOLY_LIGHT,
                CollectibleType.COLLECTIBLE_ATHAME,
                CollectibleType.COLLECTIBLE_APPLE,
                CollectibleType.COLLECTIBLE_PARASITOID,
                CollectibleType.COLLECTIBLE_YO_LISTEN,
                CollectibleType.COLLECTIBLE_GHOST_PEPPER,
                CollectibleType.COLLECTIBLE_BIRDS_EYE,
                CollectibleType.COLLECTIBLE_LODESTONE,
                CollectibleType.COLLECTIBLE_EVIL_CHARM,
                CollectibleType.COLLECTIBLE_GLASS_EYE,
                Astro.Collectible.CLOVER,
                CollectibleType.COLLECTIBLE_DADS_LOST_COIN,
                Astro.Collectible.FORTUNE_COIN,
                Astro.Collectible.PIRATE_MAP,
                Astro.Collectible.DIVINE_LIGHT,
                Astro.Collectible.BLOOD_OF_HATRED,
                Astro.Collectible.ACUTE_SINUSITIS
            }

            -- 아케이드방
            Astro.Data.ArcadePool = {
                CollectibleType.COLLECTIBLE_DINNER,
                Astro.Collectible.FORTUNE_COIN,
            }
        end
    end
)

---@param rng RNG
function Astro:GetIssacPoolCollectible(rng)
    local collectables = Astro:GetRandomCollectibles(Astro.Data.IsaacPool, rng, 1)

    if collectables[1] == nil then
        collectables[1] = CollectibleType.COLLECTIBLE_BREAKFAST
    else
        for index, value in ipairs(Astro.Data.IsaacPool) do
            if value == collectables[1] then
                table.remove(Astro.Data.IsaacPool, index)
                break
            end
        end
    end

    return collectables[1]
end

---@param rng RNG
function Astro:GetBarrenPoolCollectible(rng)
    local collectables = Astro:GetRandomCollectibles(Astro.Data.BarrenPool, rng, 1)

    if collectables[1] == nil then
        collectables[1] = CollectibleType.COLLECTIBLE_BREAKFAST
    else
        for index, value in ipairs(Astro.Data.BarrenPool) do
            if value == collectables[1] then
                table.remove(Astro.Data.BarrenPool, index)
                break
            end
        end
    end

    return collectables[1]
end

---@param rng RNG
function Astro:GetArcadePoolCollectible(rng)
    local collectables = Astro:GetRandomCollectibles(Astro.Data.ArcadePool, rng, 1)

    if collectables[1] == nil then
        collectables[1] = CollectibleType.COLLECTIBLE_BREAKFAST
    else
        for index, value in ipairs(Astro.Data.ArcadePool) do
            if value == collectables[1] then
                table.remove(Astro.Data.ArcadePool, index)
                break
            end
        end
    end

    return collectables[1]
end

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    function(_, rng)
        Astro:ScheduleForUpdate(
            function()
                local room = Game():GetRoom()
                local level = Game():GetLevel()

                if room:GetType() == RoomType.ROOM_BOSS and level:GetStage() <= LevelStage.STAGE1_2 and not level:IsAltStage() then
                    for _, value in pairs(Astro:GetDoors()) do
                        local door = value ---@type GridEntityDoor

                        if door:IsOpen() == false then
                            door:TryUnlock(Isaac.GetPlayer(), true)
                        end
                    end
                end
            end,
            1
        )
    end
)

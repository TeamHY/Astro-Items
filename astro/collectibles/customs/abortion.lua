---

local SPAWN_CHANCE = 0.5

local LUCK_MULTIPLY = 1 / 100

local COOLDOWN_TIME = 15 -- 30 프레임 = 1초

local SYNERGY_COOLDOWN_TIME = 60

---

Astro.Collectible.ABORTION = Isaac.GetItemIdByName("Abortion")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ABORTION,
                "낙태",
                "태아 공격?",
                "{{Collectible678}} 공격 시 50%의 확률로 적 명중 시 태아로 변하는 눈물을 발사합니다." ..
                "#중첩 시 최종 확률이 합 연산으로 증가하고 쿨타임이 줄어듭니다." ..
                "#{{LuckSmall}} 행운 50 이상일 때 100% 확률 (행운 1당 +1%p)"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        local tearData = tear:GetData()

        if player ~= nil and player:HasCollectible(Astro.Collectible.ABORTION) and not player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
            local data = player:GetData()

            if (data["abortionCooldown"] == nil or data["abortionCooldown"] < Game():GetFrameCount()) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.ABORTION)
                local collectibleNum = player:GetCollectibleNum(Astro.Collectible.ABORTION)

                if rng:RandomFloat() < (SPAWN_CHANCE + player.Luck * LUCK_MULTIPLY) * collectibleNum then
                    tearData.Abortion = {}
                    tear.Color = Color(1, 0.1, 0.2, 1, 0, 0, 0)
                    
                    data["abortionCooldown"] = Game():GetFrameCount() + COOLDOWN_TIME / collectibleNum
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_TEAR_COLLISION,
    ---@param tear EntityTear
    ---@param collider Entity
    ---@param low boolean
    function(_, tear, collider, low)
        if tear:GetData().Abortion ~= nil then
            tear:AddTearFlags(TearFlags.TEAR_FETUS | TearFlags.TEAR_SPECTRAL)
            tear:ChangeVariant(TearVariant.FETUS)

            tear:GetData().Abortion = nil
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)
        local entityData = entity:GetData()

        if player ~= nil and entityData.AquariusSynergy == nil and player:HasCollectible(Astro.Collectible.ABORTION) and player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) and entity:IsVulnerableEnemy() then
            if
                source.Type == EntityType.ENTITY_TEAR or
                    damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or
                    source.Type == EntityType.ENTITY_KNIFE
             then
                entityData.AquariusSynergy = {
                    Source = player,
                    StartTime = Game().TimeCounter,
                    Delay = math.floor(SYNERGY_COOLDOWN_TIME / player:GetCollectibleNum(Astro.Collectible.ABORTION))
                }
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            local data = entity:GetData().AquariusSynergy

            if data ~= nil then
                ---@type EntityPlayer
                local player = data.Source

                if player ~= nil and entity:IsVulnerableEnemy() and (Game().TimeCounter - data.StartTime) % data.Delay == 0 then
                    local splashTear =
                        player:FireTear(
                        entity.Position,
                        Vector(player.ShotSpeed * 10, 0):Rotated(math.random(360)),
                        true,
                        true,
                        false
                    )
                    splashTear.FallingSpeed = player.TearHeight * .5 * (math.random() * .75 + .5)
                    splashTear.FallingAcceleration = 1.3
                    splashTear.TearFlags = splashTear.TearFlags | TearFlags.TEAR_PIERCING
                    splashTear:AddTearFlags(TearFlags.TEAR_FETUS | TearFlags.TEAR_SPECTRAL)
                    splashTear:ChangeVariant(TearVariant.FETUS)
                    splashTear.Color = Color(1, 0.1, 0.2, 1, 0, 0, 0)
                end
            end
        end
    end
)

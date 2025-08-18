---

local TAANA_SPEED = 10 -- 에이플 날아가는 속도

local SEERI_CHANCE = 1

local SEERI_CHANCE_LUCK_MULTIPLY = 0.01 -- 행운 1당 1% 소환 확률 증가

local SEERI_COOLDOWN_TIME = 300

local SEERI_MAX_COUNT = 5 -- 리틀 스티븐 최대 소환 갯수

local KAAEN_CHANCE = 0.2

local KAAEN_SOUND = SoundEffect.SOUND_THUMBSUP

local KAAEN_SOUND_VOLUME = 1

---

Astro.Collectible.TAANA_DEFENSE_HELPER = Isaac.GetItemIdByName("TAANA - Defense Helper")
Astro.Collectible.SEERI_COMBAT_HELPER = Isaac.GetItemIdByName("SEERI the Combat Helper")
Astro.Collectible.KAAEN_AUTO_RELOADER = Isaac.GetItemIdByName("KAAEN - Auto Reloader")

local TAANA_VARIANT = Isaac.GetEntityVariantByName("TAANA - Defense Helper")
local SEERI_VARIANT = Isaac.GetEntityVariantByName("SEERI the Combat Helper")
local KAAEN_VARIANT = Isaac.GetEntityVariantByName("KAAEN - Auto Reloader")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.TAANA_DEFENSE_HELPER,
                "TAANA - 방어 도우미",
                "...",
                "{{Trinket145}} Perfection이 사라지기 전에 주울 수 있습니다. (스테이지당 1번 가능)"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.SEERI_COMBAT_HELPER,
                "SEERI - 전투 도우미",
                "...",
                "공격 시 1%의 확률로 그 방에서 {{Collectible100}}Little Steven을 소환합니다.#{{Blank}} {{ColorGray}}(최대 5개까지 소환 가능){{CR}}" ..
                "#!!! {{LuckSmall}}행운 수치 비례: 행운 99 이상일 때 100% 확률 (행운 1당 +1%p)"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.KAAEN_AUTO_RELOADER,
                "KAAEN - 재장전 도우미",
                "...",
                "방 클리어 시 20% 확률로 {{Crafting19}}리틀 배터리를 소환합니다."
            )
        end
    end
)

--#region TAANA

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:AddToFollowers()

        local sprite = familiar:GetSprite()
	    sprite:Play("idle")
    end,
    TAANA_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:FollowParent()
    end,
    TAANA_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.Taana = {
                Count = 0
            }
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        Astro.Data.Taana = {
            Count = 0
        }
    end
)

--- astro/callbacks.lua에 추가 구현이 있습니다.
---@param effect EntityEffect
local function ChangePerfection(effect)
    local position = effect.Position
    local dir = 2 * math.pi * math.random()
    local velocity = Vector(math.cos(dir), math.sin(dir)) * TAANA_SPEED

    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_PERFECTION, position, velocity, nil):ToPickup().Timeout = 60

    Astro:ScheduleForUpdate(function()
        if not Astro:HasTrinket(TrinketType.TRINKET_PERFECTION) then
            Isaac.RunCallback(Astro.Callbacks.REMOVED_PERFECTION, position)
        end
    end, 61)

    effect:Remove()
end

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    ---@param effect EntityEffect
    function (_, effect)
        if effect.SubType ~= 100 then
            return
        end

        if not Astro.Data.Taana then
            Astro.Data.Taana = {
                Count = 0
            }
        end

        local entities = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, TAANA_VARIANT)

        for i, e in ipairs(entities) do
            print(i, Astro.Data.Taana.Count + 1)
            if i == Astro.Data.Taana.Count + 1 then
                local familiar = e:ToFamiliar()
                familiar:GetSprite():Play("activated")

                ChangePerfection(effect)
                Astro.Data.Taana.Count = Astro.Data.Taana.Count + 1
                break
            end
        end
    end,
    EffectVariant.POOF01
)

--#endregion

--#region SEERI

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:AddToFollowers()

        local sprite = familiar:GetSprite()
        sprite:Play("idle")
    end,
    SEERI_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:FollowParent()

        local sprite = familiar:GetSprite()

        if sprite:IsFinished("activated") then
            sprite:Play("idle")
        end
    end,
    SEERI_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local entities = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.LITTLE_STEVEN, SEERI_VARIANT)

        for _, e in ipairs(entities) do
            e:Die()
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)

        if not player:HasCollectible(Astro.Collectible.SEERI_COMBAT_HELPER) then
            return
        end

        local stevenCount = #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.LITTLE_STEVEN, SEERI_VARIANT)

        if stevenCount >= SEERI_MAX_COUNT then
            return
        end

        local entities = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, SEERI_VARIANT)

        for _, e in ipairs(entities) do
            local familiar = e:ToFamiliar()
            local familiarPlayer = familiar.Player
            local data = familiar:GetData()

            -- 의도대로 작동하지 않음
            -- if player ~= familiarPlayer then
            --     goto continue
            -- end
            
            if data["spawnCooldown"] ~= nil and data["spawnCooldown"] >= Game():GetFrameCount() then
                goto continue
            end
            
            local colRNG = familiarPlayer:GetCollectibleRNG(Astro.Collectible.SEERI_COMBAT_HELPER)
            
            if colRNG:RandomFloat() < SEERI_CHANCE + familiarPlayer.Luck * SEERI_CHANCE_LUCK_MULTIPLY then
                familiar:GetSprite():Play("activated")
                Astro:Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.LITTLE_STEVEN, SEERI_VARIANT, familiar.Position)
                data["spawnCooldown"] = Game():GetFrameCount() + SEERI_COOLDOWN_TIME
            end

            ::continue::
        end
    end
)

--#endregion

--#region KAAEN

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:AddToFollowers()

        local sprite = familiar:GetSprite()
        sprite:Play("idle")
    end,
    KAAEN_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:FollowParent()

        local sprite = familiar:GetSprite()

        if sprite:IsFinished("activated") then
            sprite:Play("idle")
        end
    end,
    KAAEN_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        local entities = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, KAAEN_VARIANT)

        for _, e in ipairs(entities) do
            local familiar = e:ToFamiliar()
            local colRNG = familiar.Player:GetCollectibleRNG(Astro.Collectible.KAAEN_AUTO_RELOADER)

            if colRNG:RandomFloat() < KAAEN_CHANCE then
                familiar:GetSprite():Play("activated")
                SFXManager():Play(KAAEN_SOUND, KAAEN_SOUND_VOLUME)
                Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 2, familiar.Position)
            end
        end
    end
)

--#endregion

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        player:CheckFamiliar(TAANA_VARIANT, player:GetCollectibleNum(Astro.Collectible.TAANA_DEFENSE_HELPER), player:GetCollectibleRNG(Astro.Collectible.TAANA_DEFENSE_HELPER))
        player:CheckFamiliar(SEERI_VARIANT, player:GetCollectibleNum(Astro.Collectible.SEERI_COMBAT_HELPER), player:GetCollectibleRNG(Astro.Collectible.SEERI_COMBAT_HELPER))
        player:CheckFamiliar(KAAEN_VARIANT, player:GetCollectibleNum(Astro.Collectible.KAAEN_AUTO_RELOADER), player:GetCollectibleRNG(Astro.Collectible.KAAEN_AUTO_RELOADER))
    end,
    CacheFlag.CACHE_FAMILIARS
)

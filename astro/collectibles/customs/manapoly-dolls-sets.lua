---

local KAAEN_SPAWN_CHANCE = 0.5

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
                ""
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.SEERI_COMBAT_HELPER,
                "SEERI - 전투 도우미",
                "...",
                ""
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.KAAEN_AUTO_RELOADER,
                "KAAEN - 재장전 도우미",
                "...",
                "방 클리어 시 1% 확률로 작은 배터리를 소환합니다."
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
    end,
    SEERI_VARIANT
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
        local sprite = familiar:GetSprite()

        if sprite:IsPlaying("idle") then
            familiar:FollowParent()
        end

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

        for _, familiar in ipairs(entities) do
            local familiar = familiar:ToFamiliar()
            local colRNG = familiar.Player:GetCollectibleRNG(Astro.Collectible.KAAEN_AUTO_RELOADER)

            if colRNG:RandomFloat() < KAAEN_SPAWN_CHANCE then
                familiar:GetSprite():Play("activated")
                SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
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

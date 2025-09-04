---

local COOLDOWN_TIME = 150

---

Astro.Collectible.SNAKE_EYES_POPLAR = Isaac.GetItemIdByName("Snake-Eyes Poplar")

local FAMILIAR_VARIANT = Isaac.GetEntityVariantByName("Snake-Eyes Poplar")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SNAKE_EYES_POPLAR,
                "스네이크아이즈 포프루스",
                "원죄보에서 태어난 존재",
                "5초마다 랜덤 유령을 하나 소환합니다."
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.SNAKE_EYES_POPLAR),
                { Astro.Players.DIABELLSTAR, Astro.Players.DIABELLSTAR_B },
                {
                    "하나",
                    "{{ColorIsaac}}2{{CR}}마리"
                },
                nil, "ko_kr", nil
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:AddToFollowers()

        local sprite = familiar:GetSprite()
	    sprite:Play("Idle")
    end,
    FAMILIAR_VARIANT
)

---@param rng RNG
local function SpawnGhost(rng, position, spawner)
    local random = rng:RandomInt(3)

    if random == 0 then
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, position, Vector.Zero, spawner)
        effect:GetSprite():Play("Charge", false)
    elseif random == 1 then
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 0, position, Vector.Zero, spawner)
        local data = effect:GetData()

        if not data.Astro then
            data.Astro = {}
        end

        data.Astro.KillFrame = Game():GetFrameCount() + 7 * 30
    else
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, position, Vector.Zero, spawner)
        local data = effect:GetData()

        if not data.Astro then
            data.Astro = {}
        end

        data.Astro.KillFrame = Game():GetFrameCount() + 10 * 30
    end
end

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:FollowParent()

        local data = familiar:GetData()
        local room = Game():GetRoom()

        if data["cooldown"] == nil then
            data["cooldown"] = 0
        end

        if not room:IsClear() and data["cooldown"] <= Game():GetFrameCount() then
            local player = familiar.Player
            local rng = player:GetCollectibleRNG(Astro.Collectible.SNAKE_EYES_POPLAR)
            local position = Vector(familiar.Position.X, familiar.Position.Y)

            SpawnGhost(rng, position, player)

            if Astro:IsDiabellstar(player) then
                SpawnGhost(rng, position, player)
            end

            data["cooldown"] = Game():GetFrameCount() + COOLDOWN_TIME
        end
    end,
    FAMILIAR_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local count = player:GetCollectibleNum(Astro.Collectible.SNAKE_EYES_POPLAR)
        local rng = player:GetCollectibleRNG(Astro.Collectible.SNAKE_EYES_POPLAR)

        player:CheckFamiliar(FAMILIAR_VARIANT, count, rng)
    end,
    CacheFlag.CACHE_FAMILIARS
)

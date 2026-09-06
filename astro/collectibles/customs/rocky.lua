---

local XENONITE_CHANCE = 0.25

local FIRE_DELAY = 20

local DAMAGE_MULTIPLIER = 0.5

local TEAR_SPEED = 10

local MIN_TEAR_DAMAGE_MULTIPLIER = 0.5

local MAX_TEAR_DAMAGE_MULTIPLIER = 2.0

local FORGOTTEN_LULLABY_MULTIPLIER = 2

local ATTACK_ANIMATION_LENGTH = 30

local ATTACK_FIRE_FRAME = 18

local DIALOGUE_DURATION = 75

---

Astro.Collectible.ROCKY = Isaac.GetItemIdByName("Rocky")

local ITEM_ID = Astro.Collectible.ROCKY

local FAMILIAR_VARIANT = Isaac.GetEntityVariantByName("Rocky")

local CROSS_DIRECTIONS = {
    Vector(1, 0),
    Vector(-1, 0),
    Vector(0, 1),
    Vector(0, -1),
}

local DIALOGUES = {
    ["ko_kr"] = {
        "그레이스 로키 별들을 구한다",
        "너 걱정. 나 너 걱정.",
        "야, 너 얼굴에서 물 새!",
        "로키 못 잊음. 난 아무것도 못 줬음",
        "행복! 행복, 행복, 행복!",
    },
    ["en_us"] = {
        "Grace, Rocky save stars",
        "You worry. I worry you.",
        "Hey, your face is leaking!",
        "Rocky not forget. I give nothing.",
        "Happy! Happy, happy, happy!",
    },
}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "로키",
                "에리디언 종족",
                "캐릭터를 따라다니는 패밀리어입니다." ..
                "#공격 버튼을 누르면 십자 방향으로 지형 파괴 눈물을 발사합니다." ..
                "#{{Quality0}}/{{Quality1}}등급 아이템 등장 시 " .. (XENONITE_CHANCE * 100) ..
                "%의 확률로 {{Collectible" .. Astro.Collectible.XENONITE .. "}}Xenonite로 바꿉니다." ..
                "#방 클리어 시 대사를 출력합니다.",
                -- 중첩 시
                "중첩 시 Xenonite로 바뀔 확률이 중첩된 수만큼 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Rocky", "",
                "A familiar that follows Isaac" ..
                "#Fires terrain-destroying tears in a cross-shaped pattern while shooting" ..
                "#{{Quality0}}/{{Quality1}} quality items have a " .. (XENONITE_CHANCE * 100) ..
                "% chance to become {{Collectible" .. Astro.Collectible.XENONITE .. "}}Xenonite",
                -- Stacks
                "Stacks increase the Xenonite chance",
                "en_us"
            )
        end

        Astro:AddRerollCondition(
            ---@param selectedCollectible CollectibleType
            function(selectedCollectible)
                if selectedCollectible == Astro.Collectible.XENONITE then
                    return false
                end

                local itemConfigItem = Isaac.GetItemConfig():GetCollectible(selectedCollectible)

                if itemConfigItem == nil or itemConfigItem.Quality > 1 then
                    return false
                end

                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)

                    if player:HasCollectible(ITEM_ID) then
                        local rng = player:GetCollectibleRNG(ITEM_ID)

                        if rng:RandomFloat() < XENONITE_CHANCE then
                            return {
                                reroll = true,
                                newItem = Astro.Collectible.XENONITE,
                                modifierName = "Rocky"
                            }
                        end

                        return false
                    end
                end

                return false
            end
        )
    end
)

---@param familiar EntityFamiliar
---@param animation string
---@param playbackSpeed number?
---@param force boolean?
local function PlayAnimation(familiar, animation, playbackSpeed, force)
    local data = familiar:GetData()

    if force or data["rockyAnimation"] ~= animation then
        local sprite = familiar:GetSprite()

        data["rockyAnimation"] = animation
        sprite.PlaybackSpeed = playbackSpeed or 1
        sprite:Play(animation, true)
    end
end

---@param player EntityPlayer
---@return integer
local function GetFireDelay(player)
    local lullabyNum = player:GetTrinketMultiplier(TrinketType.TRINKET_FORGOTTEN_LULLABY)

    if lullabyNum <= 0 then
        return FIRE_DELAY
    end

    return math.max(1, math.floor(FIRE_DELAY / (FORGOTTEN_LULLABY_MULTIPLIER ^ lullabyNum)))
end

---@param familiar EntityFamiliar
---@param player EntityPlayer
local function FireCrossTears(familiar, player)
    local rng = familiar:GetDropRNG()
    local range = MAX_TEAR_DAMAGE_MULTIPLIER - MIN_TEAR_DAMAGE_MULTIPLIER
    local damage = player.Damage * DAMAGE_MULTIPLIER
    local isHoming = player:HasTrinket(TrinketType.TRINKET_BABY_BENDER)

    for _, direction in ipairs(CROSS_DIRECTIONS) do
        local tear = familiar:FireProjectile(direction)

        tear.Velocity = direction * TEAR_SPEED
        tear:ChangeVariant(TearVariant.ROCK)
        tear:AddTearFlags(TearFlags.TEAR_ROCK)
        tear.CollisionDamage = damage * (rng:RandomFloat() * range + MIN_TEAR_DAMAGE_MULTIPLIER)

        if isHoming then
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:AddToFollowers()

        PlayAnimation(familiar, "Idle")
    end,
    FAMILIAR_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        familiar:FollowParent()

        local sprite = familiar:GetSprite()
        local data = familiar:GetData()
        local player = familiar.Player

        if familiar.FireCooldown > 0 then
            familiar.FireCooldown = familiar.FireCooldown - 1
        end

        if player and player:GetFireDirection() ~= Direction.NO_DIRECTION and familiar.FireCooldown <= 0 then
            local fireDelay = GetFireDelay(player)

            familiar.FireCooldown = fireDelay
            data["rockyPendingFire"] = true
            PlayAnimation(familiar, "Attack", math.max(1, ATTACK_ANIMATION_LENGTH / fireDelay), true)
        end

        local currentAnimation = data["rockyAnimation"]

        -- 내려찍는 프레임에 도달했을 때 발사한다
        if data["rockyPendingFire"] then
            if currentAnimation ~= "Attack" then
                data["rockyPendingFire"] = nil
            elseif player and sprite:GetFrame() >= ATTACK_FIRE_FRAME then
                data["rockyPendingFire"] = nil

                FireCrossTears(familiar, player)
            end
        end

        if currentAnimation == "Attack" or currentAnimation == "Interaction" then
            if sprite:IsFinished(currentAnimation) then
                data["rockyAnimation"] = nil
            else
                return
            end
        end

        if familiar.Velocity.X > 0.5 then
            PlayAnimation(familiar, "WalkRight")
        elseif familiar.Velocity.X < -0.5 then
            PlayAnimation(familiar, "WalkLeft")
        else
            PlayAnimation(familiar, "Idle")
        end
    end,
    FAMILIAR_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function(_)
        local dialogues = (Options.Language == "kr" or REPKOR) and DIALOGUES["ko_kr"] or DIALOGUES["en_us"]

        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FAMILIAR_VARIANT)) do
            local familiar = entity:ToFamiliar()

            if familiar then
                local rng = familiar:GetDropRNG()

                Astro:ShowDialogue(familiar, dialogues[rng:RandomInt(#dialogues) + 1], DIALOGUE_DURATION)
                PlayAnimation(familiar, "Interaction")
                break
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    function(_, player)
        local itemNum = player:GetCollectibleNum(ITEM_ID) + player:GetEffects():GetCollectibleEffectNum(ITEM_ID)

        player:CheckFamiliar(
            FAMILIAR_VARIANT,
            itemNum,
            player:GetCollectibleRNG(ITEM_ID),
            Isaac.GetItemConfig():GetCollectible(ITEM_ID)
        )
    end,
    CacheFlag.CACHE_FAMILIARS
)

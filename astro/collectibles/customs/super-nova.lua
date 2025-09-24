---

local LASER_DURATION = 60

local LASER_DAMAGE_MULTIPLY = 0.35

-- 90도 마다 레이저가 생성됩니다. (360도 / 90도 = 4개)
local LASER_ANGLE_STEP = 30

local LASER_ALPHA = 0.5 -- 레이저 투명도

local SPAWN_CHANCE = 0.1 -- 기본 발동 확률

local LUCK_MULTIPLY = 3 / 100 -- 행운 1당 +3%p

local COOLDOWN_TIME = 450 -- 30 프레임 = 1초 (쿨타임)

---

Astro.Collectible.SUPER_NOVA = Isaac.GetItemIdByName("Super Nova")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SUPER_NOVA,
                "초신성",
                "광활한 별들의 폭발",
                "적 명중 시 10%의 확률로 십자 모양 광선을 소환합니다." ..
                "#{{TimerSmall}} (쿨타임 15초)" ..
                "#{{LuckSmall}} 행운 30 이상일 때 100% 확률 (행운 1당 +3%p)",
                -- 중첩 시
                "소환 확률이 중첩된 수만큼 합 연산으로 증가하며 쿨타임이 줄어듭니다."
            )
        end
    end
)

local SUPER_NOVA_VARIANT = Isaac.GetEntityVariantByName("Super Nova");

local ROCK_SEARCH_RANGE = 15
local ROCK_SEARCH_ANGLE_STEP = LASER_ANGLE_STEP

local function ConstructDictionaryFromTable(oldTable)
    local dictionary = {}

    for _, v in pairs(oldTable) do
        dictionary[v] = true
    end

    return dictionary
end

local GRID_DESTRUCTION_WHITELIST = ConstructDictionaryFromTable({
    GridEntityType.GRID_POOP,
    GridEntityType.GRID_ROCK,
    GridEntityType.GRID_ROCKB,
    GridEntityType.GRID_ROCKT,
    GridEntityType.GRID_ROCK_ALT,
    GridEntityType.GRID_ROCK_ALT2,
    GridEntityType.GRID_ROCK_BOMB,
    GridEntityType.GRID_ROCK_GOLD,
    GridEntityType.GRID_ROCK_SPIKED,
    GridEntityType.GRID_ROCK_SS,
    GridEntityType.GRID_TNT,
})

---@param player EntityPlayer
---@param position Vector
local function RunAttack(player, position)
    for angle = 0, 360, LASER_ANGLE_STEP do
        local laser = EntityLaser.ShootAngle(LaserVariant.LIGHT_BEAM, position, angle, LASER_DURATION, Vector.Zero, player)
        laser.CollisionDamage = player.Damage * LASER_DAMAGE_MULTIPLY
        laser.OneHit = false
        laser.DisableFollowParent = true
        laser:GetData().AstroSuperNovaLaser = true
        laser:GetSprite().Color = Color(1, 1, 1, LASER_ALPHA)
    end

    for _, projectile in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
        projectile:Die()
    end
end

---@param position Vector
---@param source Entity
local function DestroyGridAtPosition(position, source)
    local room = Game():GetRoom()
    local gridEntity = room:GetGridEntityFromPos(position)

    if gridEntity then
        if gridEntity:GetType() == GridEntityType.GRID_DOOR then
            local door = gridEntity:ToDoor()
            if door:CanBlowOpen() then
                door:TryBlowOpen(true, source)
            end
        elseif GRID_DESTRUCTION_WHITELIST[gridEntity:GetType()] then
            gridEntity:Destroy(false)
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_LASER_UPDATE,
    ---@param laser EntityLaser
    function (_, laser)
        if laser.FrameCount ~= 2 then
            return
        end
        local data = laser:GetData()
        if not data.AstroSuperNovaLaser then
            return
        end

        local samples = laser:GetNonOptimizedSamples()
        for i = 0, #samples - 1 do
            local point = samples:Get(i)
            DestroyGridAtPosition(point, laser)
            for angle = 0, 360, ROCK_SEARCH_ANGLE_STEP do
                local pointOffset = Vector.One:Rotated(angle) * ROCK_SEARCH_RANGE
                DestroyGridAtPosition(point + pointOffset, laser)
            end
        end
    end,
    LaserVariant.LIGHT_BEAM
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function (_, effect)
        local sprite = effect:GetSprite()

        if sprite:IsPlaying("Idle") then
            sprite:Play("Attack")
            return
        end

        if sprite:IsPlaying("Attack") and not sprite:WasEventTriggered("Attack") then
            effect.PositionOffset = effect.PositionOffset - Vector(0, 2)
        end

        if sprite:IsEventTriggered("Attack") then
            -- check for player's existance. naturally it'll always have a player, but spawning in from dev console can cause issues.
            -- we dont want it to error cause it is nice to be able to test the animations
            local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()
            if player then
                RunAttack(player, effect.Position+Vector(0,-10))
            end
        end

        if sprite:IsFinished("Attack") then
            effect:Remove()
        end
    end,
    SUPER_NOVA_VARIANT
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

        if player ~= nil then
            local data = player:GetData()

            if (data["superNovaCooldown"] == nil or data["superNovaCooldown"] < Game():GetFrameCount()) and player:HasCollectible(Astro.Collectible.SUPER_NOVA) and entity:IsVulnerableEnemy() then
                -- 레이저는 무한 생성되므로 제외
                if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                    local rng = player:GetCollectibleRNG(Astro.Collectible.SUPER_NOVA)
                    local baseChance = SPAWN_CHANCE * player:GetCollectibleNum(Astro.Collectible.SUPER_NOVA)

                    if rng:RandomFloat() < baseChance + player.Luck * LUCK_MULTIPLY then
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, SUPER_NOVA_VARIANT, 0, entity.Position, Vector.Zero, player)
                        effect:GetSprite().Color = Color(1, 1, 1, LASER_ALPHA)

                        data["superNovaCooldown"] = Game():GetFrameCount() + COOLDOWN_TIME / player:GetCollectibleNum(Astro.Collectible.SUPER_NOVA)
                    end
                end
            end
        end
    end
)

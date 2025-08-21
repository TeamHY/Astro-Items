---

local SHOT_SOUND_VOLUME = 1

local LASER_DURATION = 60

local LASER_DAMAGE_MULTIPLY = 2

local LASER_SCALE = 2 -- Repentogon에서만 적용됩니다.

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.ZOLTRAAK = Isaac.GetItemIdByName("Zoltraak")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.ZOLTRAAK,
        "졸트라크",
        "사람을 죽이는 마법",
        "사용 시 공격방향으로 {{DamageSmall}}공격력 2배의 광선을 발사합니다."
    )
end

local ZOLTRAAK_STAFF_VARIANT = Isaac.GetEntityVariantByName("Zoltraak Staff")
local ZOLTRAAK_STAFF_MAGIC_VARIANT = Isaac.GetEntityVariantByName("Zoltraak Staff Magic")
local ZOLTRAAK_SHOT_SOUND = Isaac.GetSoundIdByName("ZoltraakShot")
local ORBIT_DISTANCE = 20

local rotationSprings = {}

local function GetOrbitPosition(centerPosition, angle, distance)
    local angleRad = math.rad(angle)
    local offsetX = math.cos(angleRad) * distance
    local offsetY = math.sin(angleRad) * distance
    return centerPosition + Vector(offsetX, offsetY)
end

local function CreateStaffForPlayer(player)
    local staff = Isaac.Spawn(EntityType.ENTITY_EFFECT, ZOLTRAAK_STAFF_VARIANT, 0, player.Position, Vector.Zero, player)
    staff.Parent = player

    local sprite = staff:GetSprite()
    sprite:Play("Rotation", true)
    sprite:Stop()
    sprite.Offset = Vector(0, -10)
    
    local effectIndex = GetPtrHash(staff)
    rotationSprings[effectIndex] = Astro.SpringAnimation.SpringRotation:FromPreset(
        90,
        Astro.SpringAnimation.SpringAnimation.Presets.SNAPPY
    )
    
    staff.Position = GetOrbitPosition(player.Position, 90, ORBIT_DISTANCE)
    return staff
end

local function RemoveStaffForPlayer(player)
    for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ZOLTRAAK_STAFF_VARIANT)) do
        if entity.Parent == player then
            local effectIndex = GetPtrHash(entity)
            rotationSprings[effectIndex] = nil
            entity:Remove()
            return
        end
    end
end

local function HasStaffForPlayer(player)
    for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ZOLTRAAK_STAFF_VARIANT)) do
        if entity.Parent == player then
            return true
        end
    end
    return false
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, ZOLTRAAK_STAFF_MAGIC_VARIANT, 0, player.Position, Vector.Zero, player)
        effect.Parent = player

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = false,
        }
    end,
    Astro.Collectible.ZOLTRAAK
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local player = effect.Parent:ToPlayer()

        if not player then return end
        
        if not player:HasCollectible(Astro.Collectible.ZOLTRAAK) then
            local effectIndex = GetPtrHash(effect)
            rotationSprings[effectIndex] = nil
            effect:Remove()
            return
        end

        local shootingInput = player:GetShootingInput()
        local isInputActive = shootingInput.X ~= 0 or shootingInput.Y ~= 0
        
        local effectIndex = GetPtrHash(effect)
        
        if not rotationSprings[effectIndex] then
            rotationSprings[effectIndex] = Astro.SpringAnimation.SpringRotation:FromPreset(
                90,
                Astro.SpringAnimation.SpringAnimation.Presets.SNAPPY
            )
        end
        
        local rotationSpring = rotationSprings[effectIndex]
        
        local targetAngle = 90
        if isInputActive then
            targetAngle = math.atan(shootingInput.Y, shootingInput.X) * 180 / math.pi
            if targetAngle < 0 then
                targetAngle = targetAngle + 360
            end
            
            rotationSpring:SetTarget(targetAngle)
        end
        
        rotationSpring:Update(1/30)
        
        local currentAngle = rotationSpring:GetAngle()
        effect.Position = GetOrbitPosition(player.Position, currentAngle, ORBIT_DISTANCE)
        effect.Velocity = player.Velocity


        local sprite = effect:GetSprite()
        sprite.Rotation = currentAngle - 90

        if (isInputActive) then
            local frame = 1
            if (targetAngle >= 45 and targetAngle <= 135) then
                frame = 1 -- 아래
            elseif (targetAngle > 315 or targetAngle < 45) then
                frame = 3 -- 오른쪽
            elseif (targetAngle > 135 and targetAngle < 225) then
                frame = 7 -- 왼쪽
            else
                frame = 5 -- 위
            end
            
            sprite:SetFrame(frame)
        end
    end,
    ZOLTRAAK_STAFF_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_RENDER,
    ---@param effect EntityEffect
    function(_, effect)
        effect.Position = effect.Parent.Position
        effect.Velocity = effect.Parent.Velocity

        local sprite = effect:GetSprite()

        if sprite:IsFinished("appear") then
            sprite:Play("shot", true)
            SFXManager():Play(ZOLTRAAK_SHOT_SOUND, SHOT_SOUND_VOLUME)

            local staffs = Isaac.FindByType(EntityType.ENTITY_EFFECT, ZOLTRAAK_STAFF_VARIANT, 0, true)
        
            if #staffs == 0 then
                return
            end

            local staff = staffs[1]
            local angle = staff:GetSprite().Rotation + 90
            local player = effect.Parent:ToPlayer()

            if not player then
                return
            end

            local laser = EntityLaser.ShootAngle(LaserVariant.LIGHT_BEAM, player.Position, angle, LASER_DURATION, Vector.Zero, player)
            laser.CollisionDamage = player.Damage * LASER_DAMAGE_MULTIPLY
            laser.OneHit = false

            local laserData = laser:GetData()
            laserData["astroZoltraakLaser"] = true

            if REPENTOGON then
                laser:SetScale(LASER_SCALE)
            end
        elseif sprite:IsFinished("shot") then
            sprite:Play("disappear", true)
        elseif sprite:IsFinished("disappear") then
            effect:Remove()
        end
    end,
    ZOLTRAAK_STAFF_MAGIC_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_LASER_UPDATE,
    ---@param laser EntityLaser
    function (_, laser)
        local laserData = laser:GetData()
        if not laserData["astroZoltraakLaser"] then
            return
        end

        local staffs = Isaac.FindByType(EntityType.ENTITY_EFFECT, ZOLTRAAK_STAFF_VARIANT, 0, true)
        
        if #staffs == 0 then
            return
        end

        local staff = staffs[1]

        laser.Angle = staff:GetSprite().Rotation + 90
    end,
    LaserVariant.LIGHT_BEAM
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not HasStaffForPlayer(player) then
            CreateStaffForPlayer(player)
        end
    end,
    Astro.Collectible.ZOLTRAAK
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        RemoveStaffForPlayer(player)
    end,
    Astro.Collectible.ZOLTRAAK
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if player:HasCollectible(Astro.Collectible.ZOLTRAAK) and not HasStaffForPlayer(player) then
                CreateStaffForPlayer(player)
            end
        end
    end
)

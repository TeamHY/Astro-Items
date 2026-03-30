Astro.Collectible.QUILL_PEN = Isaac.GetItemIdByName("Quill Pen")

---

local FEATHER_INDEX = 15    -- n번 마다 깃털 다발 발사

local FEATHER_AMOUNT = 15    -- 깃털 다발의 양

local DAMAGE_MULTI = 3    -- 깃털 다발은 캐릭터의 공격력 n배 +5의 피해량을 가짐

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local rgonWarning = REPENTOGON and "" or "#!!! REPENTOGON이 없으면 눈물에만 적용"

            Astro.EID:AddCollectible(
                Astro.Collectible.QUILL_PEN,
                "깃펜",
                "하늘의 손길",
                "공격을 " .. FEATHER_INDEX .. "번 발사할 때마다 공격력 x" .. DAMAGE_MULTI .. " +5의 깃털 다발이 나갑니다." ..
                rgonWarning,
                -- 중첩 시
                "중첩 시 깃털 다발의 피해량 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.QUILL_PEN,
                "Quill Pen", "",
                "Isaac shoots a cluster of feathers every " .. FEATHER_INDEX .. " tears" .. 
                "#Feathers in the cluster deal " .. DAMAGE_MULTI .. "x Isaac's damage + 5",
                -- Stacks
                "Stacks increase feather's damage",
                "en_us"
            )
        end
    end
)

---@param player EntityPlayer
---@param customVelocity Vector
---@param rng RNG
---@return EntityProjectile
local function shootFeathers(player, customVelocity, rng)
    local feather = Isaac.Spawn(
        EntityType.ENTITY_PROJECTILE,
        13,
        ProjectileVariant.PROJECTILE_WING,
        player.Position,
        Vector(
            customVelocity.X + (-rng:RandomFloat() + rng:RandomFloat()) * 3,
            customVelocity.Y + (-rng:RandomFloat() + rng:RandomFloat()) * 3
        ),
        player
    ):ToProjectile()
    
    feather:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.NO_WALL_COLLIDE | ProjectileFlags.ANY_HEIGHT_ENTITY_HIT | ProjectileFlags.CANT_HIT_PLAYER)
    feather.Parent = player
    feather.FallingSpeed = 0
    feather.FallingAccel = -0.1
    feather.SpriteRotation = feather.Velocity:GetAngleDegrees()

    local penNum = player:GetCollectibleNum(Astro.Collectible.QUILL_PEN)
    feather.CollisionDamage = player.Damage * DAMAGE_MULTI * penNum

    local fData = feather:GetData()
    fData._ASTRO_quillPenTimeout = 300
    fData._ASTRO_quillPenPlayer = player

    return feather
end

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED,
        ---@param direction Vector
        ---@param amount integar
        ---@param isInterpolated boolean
        ---@param weapon Weapon
        function(_, direction, amount, owner, weapon)
            local player = owner:ToPlayer()
            local weaponType = weapon:GetWeaponType()

            if weapon:GetNumFired() % FEATHER_INDEX ~= 0 then return end
            if weaponType == WeaponType.WEAPON_ROCKETS or weaponType == WeaponType.WEAPON_LUDOVICO_TECHNIQUE then return end

            if player ~= nil and player:HasCollectible(Astro.Collectible.QUILL_PEN) then
                local vel = Vector(0, 0)
                local rng = player:GetCollectibleRNG(Astro.Collectible.QUILL_PEN)
                local finalFeatherAmount = FEATHER_AMOUNT

                if weaponType == WeaponType.WEAPON_KNIFE then
                    vel = weapon:GetDirection() * 10
                elseif weaponType == WeaponType.WEAPON_BRIMSTONE then
                    vel = player:GetShootingJoystick() * 10
                    finalFeatherAmount = math.floor(finalFeatherAmount / 4)
                else
                    vel = direction * 10
                end
                
                for _ = 1, finalFeatherAmount do
                    shootFeathers(player, vel, rng)
                end

                SFXManager():Play(SoundEffect.SOUND_DOGMA_FEATHER_SPRAY, 0.15)
            end
        end
    )
else
    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_TEAR,
        ---@param tear EntityTear
        function(_, tear)
            if tear.TearIndex % FEATHER_INDEX ~= 0 then return end
            local player = Astro:GetPlayerFromEntity(tear)

            if player ~= nil and player:HasCollectible(Astro.Collectible.QUILL_PEN) then
                local vel = tear.Velocity
                local rng = player:GetCollectibleRNG(Astro.Collectible.QUILL_PEN)

                for _ = 1, FEATHER_AMOUNT do
                    shootFeathers(player, vel, rng)
                end

                SFXManager():Play(SoundEffect.SOUND_DOGMA_FEATHER_SPRAY, 0.15)
            end
        end
    )
end

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local newColor = player.Color
        
        newColor:SetColorize(1, 1, 1, 1)
        player.Color = newColor
    end,
    Astro.Collectible.QUILL_PEN
)

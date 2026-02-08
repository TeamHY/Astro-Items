Astro.Collectible.QUILL_PEN = Isaac.GetItemIdByName("Quill Pen")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.QUILL_PEN,
                "깃펜",
                "하늘의 손길",
                "눈물을 15번 발사할 때마다 공격력 x2의 깃털 다발이 나갑니다.",
                -- 중첩 시
                "중첩 시 깃털 다발의 피해량 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.QUILL_PEN,
                "Quill Pen", "",
                "Isaac shoots a cluster of feathers that deal 2x his damage every 15 tear",
                -- Stacks
                "Stacks increase feather's damage",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        if tear.TearIndex % 15 ~= 0 then return end
        local player = Astro:GetPlayerFromEntity(tear)

        if player ~= nil and player:HasCollectible(Astro.Collectible.QUILL_PEN) then
            local vel = tear.Velocity
            local rng = player:GetCollectibleRNG(Astro.Collectible.QUILL_PEN)

            for _ = 1, 15 do
                local feather = Isaac.Spawn(
                    EntityType.ENTITY_PROJECTILE,
                    13,
                    ProjectileVariant.PROJECTILE_WING,
                    player.Position,
                    Vector(
                        vel.X + (-rng:RandomFloat() + rng:RandomFloat()) * 3,
                        vel.Y + (-rng:RandomFloat() + rng:RandomFloat()) * 3
                    ),
                    player
                ):ToProjectile()
                
                feather:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.NO_WALL_COLLIDE | ProjectileFlags.ANY_HEIGHT_ENTITY_HIT | ProjectileFlags.CANT_HIT_PLAYER)
                feather.Parent = player
                feather.FallingSpeed = 0
                feather.FallingAccel = -0.1
                feather.SpriteRotation = feather.Velocity:GetAngleDegrees()

                local fData = feather:GetData()
                fData._ASTRO_quillPenTimeout = 300
                fData._ASTRO_quillPenPlayer = player
            end

            SFXManager():Play(SoundEffect.SOUND_DOGMA_FEATHER_SPRAY, 0.15)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PROJECTILE_UPDATE,
    ---@param projectile EntityProjectile
    function(_, projectile)
        local fData = projectile:GetData()

        if fData._ASTRO_quillPenTimeout and fData._ASTRO_quillPenPlayer ~= nil then
            local player = fData._ASTRO_quillPenPlayer
            local penNum = player:GetCollectibleNum(Astro.Collectible.QUILL_PEN)

            fData._ASTRO_quillPenTimeout = fData._ASTRO_quillPenTimeout - 1
            projectile.CollisionDamage = player.Damage * (penNum - 0.425)

            if fData._ASTRO_quillPenTimeout < 0 then
                projectile:Remove()
            end
        end
    end,
    ProjectileVariant.PROJECTILE_WING
)
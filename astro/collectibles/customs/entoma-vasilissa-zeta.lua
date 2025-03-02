Astro.Collectible.ENTOMA_VASILISSA_ZETA = Isaac.GetItemIdByName("Entoma Vasilissa Zeta")

local CHIGGER_VARIANT = 3107

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ENTOMA_VASILISSA_ZETA,
                "엔토마 바실리사 제타타",
                "벌레를 사랑하는 메이드",
                "공격 시 진드기를 소환합니다."
            )
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

        if player ~= nil and player:HasCollectible(Astro.Collectible.ENTOMA_VASILISSA_ZETA) and entity:IsVulnerableEnemy() then
            if source.Type == EntityType.ENTITY_TEAR then
                local spd = 5.0 + math.random()
                local ang = math.rad(math.random() * 360)
                local s =
                    Game():Spawn(
                    EntityType.ENTITY_FAMILIAR,
                    CHIGGER_VARIANT,
                    entity.Position + Vector(math.cos(ang) * spd, math.sin(ang) * spd),
                    Vector(math.cos(ang) * spd, math.sin(ang) * spd),
                    player,
                    0,
                    player.InitSeed
                )
                s.CollisionDamage = amount * 2
            end

            -- if damageFlags == 0 then
            --     local lvl = Game():GetLevel()
            --     local l = lvl:GetAbsoluteStage()

            --     local fin_amt = 1.0 - (l / 12) * 0.4
            --     local d = 0.5

            --     if entity.Type == EntityType.ENTITY_HUSH then
            --         fin_amt = 1.5
            --     end

            --     if entity.Index ~= nil then
            --         if entity:IsVulnerableEnemy() then
            --             entity.HitPoints = entity.HitPoints + (amount * d) * (1.0 - fin_amt)
            --         end
            --     end
            -- end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        if familiar.FrameCount % 20 == 2 then
            ents = Isaac.GetRoomEntities()
            for i=1,#ents do
                if ents[i]:IsVulnerableEnemy() then
                    if familiar.Target == nil or ents[i].HitPoints > familiar.Target.HitPoints then if ents[i].Size > 3 then
                        familiar.Target = ents[i]
                    end end
                end
            end
        end
        if familiar.FrameCount > 80 then familiar:Kill() end
        if familiar.Target ~= nil and familiar.FrameCount % 2 == 1 or familiar.FramCount == 1 then
            familiar.Velocity = familiar.Velocity + ((familiar.Target.Position - familiar.Position):Resized(2.65+math.abs(math.cos(familiar.FrameCount / 2) * 0.5)))
            familiar.Velocity = familiar.Velocity * 0.8
        end

        if familiar.Target == nil and familiar.FrameCount > 30 then familiar:Kill() end

        if familiar.Velocity:Length() > 8 then familiar.Velocity:Resize(8) end

        if familiar.FrameCount % 3 == familiar.Index % 3 then
            ents = Isaac.GetRoomEntities()
            for i=1,#ents do
                off = ents[i].Position - familiar.Position
                if ents[i]:IsVulnerableEnemy() and math.abs(off.X) + math.abs(off.Y) < familiar.Size+32 and familiar.FrameCount > 40 then
                    familiar:Kill()
                end
            end
        end
    end,
    CHIGGER_VARIANT
)

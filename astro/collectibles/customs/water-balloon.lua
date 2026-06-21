Astro.Collectible.WATER_BALLOON = Isaac.GetItemIdByName("Water Balloon")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.WATER_BALLOON,
                "물풍선",
                "버블 앤 버블",
                "↑ {{Bomb}}폭탄 +5" ..
                "#폭탄이 터질 때 폭탄 기준 4방향으로 짧은 물대포를 발사합니다." ..
                "#{{Freezing}} 폭탄으로 적 처치시 적이 얼어붙습니다." ..
                "#이 폭탄의 폭발 공격에 피해를 입지 않습니다.",
                -- 중첩 시
                "중첩 시 물대포 공격력과 길이가 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.WATER_BALLOON,
                "Water Balloon", "",
                "↑ {{Bomb}} +5 Bombs" ..
                "#Bombs explode with short water jets in a cross-shaped pattern" ..
                "#{{Freezing}} Freezes enemies upon killing them with bombs" ..
                "#Isaac takes no damage from this bomb",
                -- Stacks
                "Stacks increase water jet damage",
                "en_us"
            )
        end
    end
)

---@param parent Entity
---@param player EntityPlayer
---@param damage number
local function shootWaterJets(parent, player, damage)
    local itemNum = player:GetCollectibleNum(Astro.Collectible.WATER_BALLOON)
    local waterColor = Color(1, 1, 1, 1)
    waterColor:SetColorize(1.05, 0.98, 1, -1)

    for angle = 0, 360, 90 do
        local laser = EntityLaser.ShootAngle(LaserVariant.SHOOP, parent.Position, angle, 15, Vector.Zero, player)
        laser:GetSprite().Color = waterColor
        laser:SetMaxDistance(40 + 40 * itemNum)
        laser.CollisionDamage = damage
        laser.DisableFollowParent = true
        laser.OneHit = true
        laser.TearFlags = laser.TearFlags | TearFlags.TEAR_ICE

        laser:GetData()._ASTRO_waterBalloonWaterJet = true
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_BOMB_UPDATE,
    ---@param bomb EntityBomb
    function(_, bomb)
        local sprite = bomb:GetSprite()
        local player = Astro:GetPlayerFromEntity(bomb)

        if player and player:HasCollectible(Astro.Collectible.WATER_BALLOON) then
            local itemNum = player:GetCollectibleNum(Astro.Collectible.WATER_BALLOON)

            if not bomb:HasTearFlags(TearFlags.TEAR_ICE) then
                bomb:AddTearFlags(TearFlags.TEAR_ICE)
            end

            if sprite:IsPlaying("Explode") then
                shootWaterJets(bomb, player, bomb.ExplosionDamage * itemNum)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local player = Astro:GetPlayerFromEntity(effect)

        if player and player:HasCollectible(Astro.Collectible.WATER_BALLOON) then
            local itemNum = player:GetCollectibleNum(Astro.Collectible.WATER_BALLOON)

            if effect.Timeout ~= -1 and effect.Timeout < 1 then
                shootWaterJets(effect, player, player.Damage * 20)
            end
        end
    end,
    EffectVariant.ROCKET
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect
    function(_, effect)
        local lasers = Isaac.FindByType(EntityType.ENTITY_LASER, LaserVariant.SHOOP)

        if #lasers > 0 then
            for _, ent in pairs(lasers) do
                local laser = ent:ToLaser()
                
                if laser and laser:HasTearFlags(TearFlags.TEAR_ICE) and laser:GetData()._ASTRO_waterBalloonWaterJet and effect.Position:Distance(laser.Position) < 10 then
                    local sfx = SFXManager()

                    if sfx:IsPlaying(SoundEffect.SOUND_BOSS1_EXPLOSIONS) then
                        sfx:Stop(SoundEffect.SOUND_BOSS1_EXPLOSIONS)
                        sfx:Play(Astro.SoundEffect.WATER_BALLOON_EXPLOSION)
                    end
                    
                    effect.Visible = false
                    effect:Remove()
                    break
                end
            end
        end
    end,
    EffectVariant.BOMB_EXPLOSION
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player ~= nil and player:HasCollectible(Astro.Collectible.WATER_BALLOON) and damageFlags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then
            if source.Entity and source.Entity:ToBomb() and source.Entity:ToBomb():HasTearFlags(TearFlags.TEAR_ICE) then
                return false
            end
        end
    end
)
Astro.Collectible.DIVINE_LIGHT = Isaac.GetItemIdByName("Divine Light")

--공격 시 확률적으로 빛줄기가 적용됩니다 (기본 10%, 럭1당10%p증가)
if EID then
    EID:addCollectible(Astro.Collectible.DIVINE_LIGHT, "", "신의 조명")
end

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(Astro.Collectible.DIVINE_LIGHT) and entity:IsVulnerableEnemy() then
            if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                local rng = player:GetCollectibleRNG(Astro.Collectible.DIVINE_LIGHT)

                if rng:RandomFloat() < 0.1 + player.Luck / 10 then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, entity.Position, Vector.Zero, player)
                end
            end
        end
    end
)
Astro.Collectible.DIVINE_LIGHT = Isaac.GetItemIdByName("Divine Light")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.DIVINE_LIGHT,
                "신의 조명",
                "앞을 밝히노니",
                "적 명중 시 10%의 확률로 빛줄기를 소환합니다." ..
                "#{{LuckSmall}} 행운 18 이상일 때 100% 확률 (행운 1당 +5%p)",
                -- 중첩 시
                "중첩된 수만큼 빛줄기 소환 시도"
            )
            
            Astro.EID:AddCollectible(
                Astro.Collectible.DIVINE_LIGHT,
                "Divine Light",
                "",
                "10% chance to summon light beams on hit" ..
                "#{{Luck}} 100% chance at 18 Luck (+5%p per Luck)",
                -- Stacks
                "Stacks summon additional light beams",
                "en_us"
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

        if player ~= nil and player:HasCollectible(Astro.Collectible.DIVINE_LIGHT) and entity:IsVulnerableEnemy() then
            if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                local rng = player:GetCollectibleRNG(Astro.Collectible.DIVINE_LIGHT)

                for _ = 1, player:GetCollectibleNum(Astro.Collectible.DIVINE_LIGHT) do
                    if rng:RandomFloat() < 0.1 + player.Luck / 20 then
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, entity.Position, Vector.Zero, player)
                    end
                end
            end
        end
    end
)

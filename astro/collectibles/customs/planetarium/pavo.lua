Astro.Collectible.PAVO = Isaac.GetItemIdByName("Pavo")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.PAVO,
                "공작자리",
                "우아한 자태",
                "{{MegaSatanSmall}} Mega Satan(1페이즈)의 체력이 10% 감소됩니다." ..
                "#Mega Satan(1페이즈)을 제외한 모든 적들의 체력이 20% 감소됩니다.",
                -- 중첩 시
                "중첩 시 체력 감소 효과가 중첩된 수만큼 곱연산으로 적용 (Mega Satan(1페이즈) 제외)"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    ---@param entity Entity
    function(_, entity)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.PAVO) then
                if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
                    if entity.Type == EntityType.ENTITY_MEGA_SATAN then
                        entity:TakeDamage(entity.HitPoints * 0.1, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
                    else
                        entity:TakeDamage(entity.HitPoints * (1 - (0.8 ^ Astro:GetCollectibleNum(Astro.Collectible.PAVO))), DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
                    end
                end

                break
            end
        end
    end
)

Astro.Collectible.PAVO = Isaac.GetItemIdByName("Pavo")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.PAVO, "공작자리", "...", "{{MegaSatanSmall}} Mega Satan(1페이즈)의 체력이 10% 감소됩니다.#Mega Satan(1페이즈)을 제외한 모든 몬스터들의 체력이 20% 감소됩니다.#중첩 시 체력 감소 효과가 곱 연산으로 적용됩니다.#{{Blank}} ({{MegaSatanSmall}}Mega Satan(1페이즈) 제외)")
end

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

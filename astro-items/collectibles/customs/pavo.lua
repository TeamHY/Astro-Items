AstroItems.Collectible.PAVO = Isaac.GetItemIdByName("Pavo")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.PAVO, "공작자리", "...", "Mega Satan 1 페이즈의 체력이 10% 감소됩니다.#Mega Satan 1 페이즈를 제외한 모든 몬스터들의 체력이 20% 감소됩니다.#중첩 시 체력 감소 효과가 곱 연산으로 적용됩니다. Mega Satan 1 페이즈는 제외합니다.")
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    ---@param entity Entity
    function(_, entity)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.PAVO) then
                if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
                    if entity.Type == EntityType.ENTITY_MEGA_SATAN then
                        entity:TakeDamage(entity.HitPoints * 0.1, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
                    else
                        entity:TakeDamage(entity.HitPoints * 0.2 ^ AstroItems:GetCollectibleNum(AstroItems.Collectible.PAVO), DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
                    end
                end

                break
            end
        end
    end
)

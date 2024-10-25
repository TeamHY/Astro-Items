---

-- 30% 추가 피해
local EXTRA_DAMAGE_MULTIPLIER = 0.3

---

AstroItems.Collectible.GALACTIC_MEDAL_OF_VALOR = Isaac.GetItemIdByName("Galactic Medal Of Valor")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.GALACTIC_MEDAL_OF_VALOR, "은하 용맹 훈장", "...", "보스 몬스터 직접 공격 시 30% 추가 피해를 입힙니다.#중첩 시 추가 피해가 합 연산으로 증가합니다.")
end

AstroItems:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = AstroItems:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(AstroItems.Collectible.GALACTIC_MEDAL_OF_VALOR) then
            if entity:IsBoss() and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * EXTRA_DAMAGE_MULTIPLIER * player:GetCollectibleNum(AstroItems.Collectible.GALACTIC_MEDAL_OF_VALOR), 0, EntityRef(player), 0)
            end
        end
    end
)

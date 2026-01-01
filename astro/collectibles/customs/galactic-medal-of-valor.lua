---

-- 30% 추가 피해
local EXTRA_DAMAGE_MULTIPLIER = 0.3

---

Astro.Collectible.GALACTIC_MEDAL_OF_VALOR = Isaac.GetItemIdByName("Galactic Medal Of Valor")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.GALACTIC_MEDAL_OF_VALOR,
                "은하 용맹 훈장",
                "용기를 치하하며",
                "공격이 보스에게 명중 시 30%의 추가 피해를 입힙니다.",
                -- 중첩 시
                "추가 피해량이 중첩된 수만큼 합 연산으로 증가"
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

        if player ~= nil and player:HasCollectible(Astro.Collectible.GALACTIC_MEDAL_OF_VALOR) then
            if entity:IsBoss() and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * EXTRA_DAMAGE_MULTIPLIER * player:GetCollectibleNum(Astro.Collectible.GALACTIC_MEDAL_OF_VALOR), 0, EntityRef(player), 0)
            end
        end
    end
)

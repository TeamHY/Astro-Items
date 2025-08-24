local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ASTRO_SACRED_HEART = Isaac.GetItemIdByName("Astro Sacred Heart")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ASTRO_SACRED_HEART,
                "광휘로운 심장",
                "유도 공격 + 공격력 증가 + 추가 피해",
                "↑ {{Heart}}최대 체력 +1" ..
                "#{{HealingRed}} 체력을 모두 회복합니다." ..
                "#↑ {{DamageSmall}}공격력 +1" ..
                "#↑ {{DamageSmall}}공격력 배율 x2.3" ..
                "#↓ {{TearsSmall}}연사 -0.4" ..
                "#↓ {{ShotspeedSmall}}탄속 -0.25" ..
                "#공격에 유도 효과가 생깁니다." ..
                "#폭탄에 유도 효과가 생깁니다." ..
                "#적이 피해를 입을 때 피해량이 2.3배로 증가합니다.",
                -- 중첩 시
                "적이 받는 피해량이 합 연산으로 증가"
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
        if entity:IsVulnerableEnemy() and source.Entity ~= nil and damageFlags & DamageFlag.DAMAGE_IV_BAG == 0 then
            local player = Astro:GetPlayerFromEntity(source.Entity)
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.ASTRO_SACRED_HEART) then
                local numAstroSacredHeart = player:GetCollectibleNum(Astro.Collectible.ASTRO_SACRED_HEART)
                entity:TakeDamage(amount * ((2.3 * numAstroSacredHeart) - 1), damageFlags | DamageFlag.DAMAGE_IV_BAG, source, countdownFrames)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_SACRED_HEART, player:HasCollectible(Astro.Collectible.ASTRO_SACRED_HEART) and 1 or 0, "ASTRO_SACRED_HEART")
    end
) 

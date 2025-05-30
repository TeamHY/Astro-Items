local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ASTRO_SACRED_HEART = Isaac.GetItemIdByName("Astro Sacred Heart")

local UPGRADE_CHANCE = 0.2

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ASTRO_SACRED_HEART,
                "아스트로 성스러운 심장",
                "...",
                "#{{Collectible182}} Sacred Heart 효과가 적용됩니다." ..
                "#적이 피해를 입을 때 피해량의 2.3배가 적용됩니다." ..
                "#{{ArrowGrayRight}}중첩 시 피해량이 합 연산으로 증가합니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if selectedCollectible == CollectibleType.COLLECTIBLE_SACRED_HEART then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.ASTRO_SACRED_HEART)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                return Astro.Collectible.ASTRO_SACRED_HEART
            end
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

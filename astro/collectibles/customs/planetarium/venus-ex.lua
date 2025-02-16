---

local EXTRA_DAMAGE_MULTIPLIER = 0.5

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.VENUS_EX = Isaac.GetItemIdByName("VENUS EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.VENUS_EX,
        "초 금성",
        "...",
        "{{Collectible591}}Venus 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#매혹 상태 적에게 50% 추가 피해를 입힙니다. 중첩 시 추가 피해가 합연산으로 증가합니다."
    )
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

        if player ~= nil and player:HasCollectible(Astro.Collectible.VENUS_EX) then
            if entity:IsVulnerableEnemy() and entity:HasEntityFlags(EntityFlag.FLAG_CHARM) and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * EXTRA_DAMAGE_MULTIPLIER * player:GetCollectibleNum(Astro.Collectible.VENUS_EX), 0, EntityRef(player), 0)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_VENUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_VENUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_VENUS)
        end
    end,
    Astro.Collectible.VENUS_EX
)

-- Astro:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_VENUS) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_VENUS)
--         end
--     end,
--     Astro.Collectible.VENUS_EX
-- )

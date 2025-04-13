local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.ASTRO_GODHEAD = Isaac.GetItemIdByName("Astro Godhead")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ASTRO_GODHEAD,
                "아스트로 갓헤드",
                "...",
                ""
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
        if amount == 2 and source.Entity ~= nil and source.Entity.Type == 2 and entity.Type ~= 1 then
            local player = Astro:GetPlayerFromEntity(source.Entity)
            local tear = source.Entity:ToTear()
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.ASTRO_GODHEAD) and tear.TearFlags & TearFlags.TEAR_GLOW == TearFlags.TEAR_GLOW then
                entity:TakeDamage(tear.BaseDamage * 0.3, damageFlags, source, countdownFrames)
                return false
            end
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_GODHEAD, player:HasCollectible(Astro.Collectible.ASTRO_GODHEAD) and 1 or 0, "ASTRO_ASTRO_GODHEAD")
    end
)

local PRICE = 10

local isc = require("astro.lib.isaacscript-common")

Astro.Entity.IBN5100 = {
    Type = EntityType.ENTITY_SLOT,
    Variant = 3105,
    SubType = 0,
}

Astro:AddCallback(
    ModCallbacks.MC_PRE_PLAYER_COLLISION,
    ---@param player EntityPlayer
    ---@param collider Entity
    ---@param low boolean
    function(_, player, collider, low)
        if collider.Type == EntityType.ENTITY_SLOT and collider.Variant == Astro.Entity.IBN5100.Variant then
            local sprite = collider:GetSprite()

            if sprite:IsPlaying("contact") then
                return
            end

            if player:GetNumCoins() < PRICE then
                return
            end

            player:AddCoins(-PRICE)

            sprite:Play("contact", true)
            SFXManager():Play(SoundEffect.SOUND_COIN_SLOT)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_UPDATE,
    function(_, slot)
        local sprite = slot:GetSprite()

        if sprite:IsFinished("spawn") then
            sprite:Play("idle")
        elseif sprite:IsFinished("contact") then
            Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, false, false, true, false)
        end

        if slot.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER then
            slot:Remove()
        end
    end,
    Astro.Entity.IBN5100.Variant
)

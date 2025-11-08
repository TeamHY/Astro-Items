---

local CHANGE_CHANCE = 0.7

local PRICE = 10

---

local isc = require("astro.lib.isaacscript-common")

Astro.Entity.GlitchedMachine = {
    Type = EntityType.ENTITY_SLOT,
    Variant = 3104,
    SubType = 0,
}

local INIT_CHECK_SUBTYPE = 1000

Astro:AddCallback(
    ModCallbacks.MC_PRE_PLAYER_COLLISION,
    ---@param player EntityPlayer
    ---@param collider Entity
    ---@param low boolean
    function(_, player, collider, low)
        if collider.Type == EntityType.ENTITY_SLOT and collider.Variant == Astro.Entity.GlitchedMachine.Variant then
            if player:GetNumCoins() < PRICE then
                return nil
            end

            local sprite = collider:GetSprite()

            if not sprite:GetAnimation() == "Idle" then
                return nil
            end

            player:AddCoins(-PRICE)
            sprite:Play("Initiate", true)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)
        local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_EVE)

        if (slot.SubType ~= INIT_CHECK_SUBTYPE and rng:RandomFloat() < CHANGE_CHANCE) or Astro:HasCollectible(Astro.Collectible.BIRTHRIGHT_CAIN) then
            slot:Remove()
            Isaac.Spawn(EntityType.ENTITY_SLOT, Astro.Entity.GlitchedMachine.Variant, 0, slot.Position, Vector(0, 0), nil)
        elseif slot.SubType ~= INIT_CHECK_SUBTYPE then
            slot.SubType = INIT_CHECK_SUBTYPE
        end
    end,
    1
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_UPDATE,
    ---@param slot Entity
    function(_, slot)
        local sprite = slot:GetSprite()

        if sprite:IsFinished("Initiate") then
            sprite:Play("Glitching")
        elseif sprite:IsFinished("Glitching") then
            sprite:Play("Death")
        elseif sprite:IsFinished("Death") then
            sprite:Play("Broken")
            slot.GridCollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
            slot:Kill()
        end

        if sprite:IsEventTriggered("Explosion") then
            local player = Isaac.GetPlayer()

            for _ = 1, 4 do
                player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, slot.Position, Vector(0, 0), nil)
            SFXManager():Play(SoundEffect.	SOUND_BOSS1_EXPLOSIONS, 1)
        end

        if slot.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER then
            sprite:Play("Broken")
            slot:Kill()
        end
    end,
    Astro.Entity.GlitchedMachine.Variant
)

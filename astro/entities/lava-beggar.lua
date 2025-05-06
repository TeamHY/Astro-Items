---

local CHANGE_CHANCE = 0.1

---

local isc = require("astro.lib.isaacscript-common")

local INIT_CHECK_SUBTYPE = 1000

local LAVA_BEGGAR_SUBTYPE = 3100

-- Astro:AddCallback(
--     ModCallbacks.MC_PRE_PLAYER_COLLISION,
--     ---@param player EntityPlayer
--     ---@param collider Entity
--     ---@param low boolean
--     function(_, player, collider, low)
--         if collider.Type == EntityType.ENTITY_SLOT and collider.Variant == 3100 then
--             local data = GetData(collider.SubType)

--             if player:GetNumCoins() < data.price then
--                 return nil
--             end

--             local sprite = collider:GetSprite()

--             if
--                 not (sprite:IsPlaying("Idle_10") or sprite:IsPlaying("Idle_15") or sprite:IsPlaying("Idle_20") or
--                     sprite:IsPlaying("Idle_25"))
--              then
--                 return nil
--             end

--             sprite:PlayOverlay("CoinInsert", true)
--             SFXManager():Play(SoundEffect.SOUND_COIN_SLOT)

--             local rng = player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_CAIN)

--             if not (player:HasCollectible(Astro.Collectible.BIRTHRIGHT_CAIN) and rng:RandomFloat() < Astro.BIRTHRIGHT_CAIN_CHANCE) then
--                 player:AddCoins(-data.price)
--             end

--             sprite:Play("Initiate")
--         end
--     end
-- )

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)        
        if slot.SubType == 0 then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_EVE)

            if rng:RandomFloat() < CHANGE_CHANCE then
                local sprite = slot:GetSprite()
                sprite:Load("gfx/lava_beggar.anm2")
                sprite:LoadGraphics()
                sprite:Play(sprite:GetDefaultAnimation(), true)

                slot.SubType = LAVA_BEGGAR_SUBTYPE
            else
                slot.SubType = INIT_CHECK_SUBTYPE
            end
        end
    end,
    4
)

-- Astro:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_SLOT_INIT,
--     ---@param slot Entity
--     function(_, slot)
--         local data = GetData(slot.SubType)
--         local collectible = data.collectible

--         local itemConfig = Isaac.GetItemConfig():GetCollectible(collectible)
--         local sprite = slot:GetSprite()

--         sprite:ReplaceSpritesheet(2, itemConfig.GfxFileName)
--         sprite:LoadGraphics()

--         if data.priceType == 0 then
--             sprite:Play("Idle_10")
--         elseif data.priceType == 1 then
--             sprite:Play("Idle_15")
--         elseif data.priceType == 2 then
--             sprite:Play("Idle_20")
--         elseif data.priceType == 3 then
--             sprite:Play("Idle_25")
--         end
--     end,
--     3100
-- )

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_UPDATE,
    ---@param slot Entity
    function(_, slot)
        local sprite = slot:GetSprite()

        if sprite:IsFinished("Initiate") then
            sprite:Play("Wiggle")
        elseif sprite:IsFinished("Wiggle") then
            sprite:Play("Prize")
            SFXManager():Play(SoundEffect.SOUND_THUMBSUP, 1)
        elseif sprite:IsFinished("Prize") then
            sprite:Play("OutOfPrizes")
        elseif sprite:IsFinished("OutOfPrizes") then
            sprite:Play("Death")
        elseif sprite:IsFinished("Death") then
            sprite:Play("Broken")
            slot.GridCollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
            slot:Kill()
        end

        if sprite:IsEventTriggered("Explosion") then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, slot.Position, Vector(0, 0), nil)
            SFXManager():Play(SoundEffect.	SOUND_BOSS1_EXPLOSIONS, 1)
        end

        if sprite:IsEventTriggered("Prize") then
            local data = GetData(slot.SubType)
            Astro:SpawnCollectible(data.collectible, slot.Position)
        end

        if slot.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER then
            sprite:Play("Broken")
            slot:Kill()
        end
    end,
    3100
)

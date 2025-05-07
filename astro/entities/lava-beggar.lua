---

-- 일반 거지에서 변경될 확률
local CHANGE_CHANCE = 0.1

-- 성공 확률 (0 ~ 1)
local SUCCESS_CHANCE = 1

-- 가격
local PRICE = 10

---

local isc = require("astro.lib.isaacscript-common")

local INIT_CHECK_SUBTYPE = 1000

local LAVA_BEGGAR_VARIANT = 3101

Astro:AddCallback(
    ModCallbacks.MC_PRE_PLAYER_COLLISION,
    ---@param player EntityPlayer
    ---@param collider Entity
    ---@param low boolean
    function(_, player, collider, low)
        if collider.Type == EntityType.ENTITY_SLOT and collider.Variant == LAVA_BEGGAR_VARIANT then
            if player:GetNumCoins() < PRICE then
                return nil
            end

            local sprite = collider:GetSprite()

            if not sprite:IsPlaying("Idle") then
                return nil
            end

            SFXManager():Play(SoundEffect.SOUND_SCAMPER)

            player:AddCoins(-PRICE)

            local rng = player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_STEVEN)

            if rng:RandomFloat() < SUCCESS_CHANCE then
                sprite:Play("PayPrize")

                local data = collider:GetData()
                data.player = player
            else
                sprite:Play("PayNothing")
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)        
        if slot.SubType == 0 then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_EVE)

            if rng:RandomFloat() < CHANGE_CHANCE then
                Isaac.Spawn(EntityType.ENTITY_SLOT, LAVA_BEGGAR_VARIANT, 0, slot.Position, Vector(0, 0), nil)
                slot:Remove()
            else
                slot.SubType = INIT_CHECK_SUBTYPE
            end
        end
    end,
    4
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)        
        slot.SpriteOffset = Vector(0, 5)
    end,
    LAVA_BEGGAR_VARIANT
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

        if sprite:IsFinished("PayPrize") then
            sprite:Play("Prize")
        elseif sprite:IsFinished("Prize") then
            sprite:Play("Idle")
        elseif sprite:IsFinished("OutOfPrizes") then
            sprite:Play("Death")
        -- elseif sprite:IsFinished("Death") then
        --     sprite:Play("Broken")
        --     slot.GridCollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
        --     slot:Kill()
        end

        -- if sprite:IsEventTriggered("Explosion") then
        --     Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, slot.Position, Vector(0, 0), nil)
        --     SFXManager():Play(SoundEffect.	SOUND_BOSS1_EXPLOSIONS, 1)
        -- end

        if sprite:IsEventTriggered("Prize") then
            SFXManager():Play(SoundEffect.SOUND_THUMBSUP, 1)

            local data = slot:GetData()

            if data.player then
                ---@type EntityPlayer
                local player = data.player
                player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
            end
        end

        if slot.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER then
            Game():GetLevel():SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)

            slot:BloodExplode()
            slot:BloodExplode()
            slot:BloodExplode()
            slot:BloodExplode()
            slot:Remove()
        end
    end,
    LAVA_BEGGAR_VARIANT
)

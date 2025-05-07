---

-- 성공 확률 (0 ~ 1)
local SUCCESS_CHANCE = 0.25

-- 가격
local PRICE = 1

---

local isc = require("astro.lib.isaacscript-common")

local PLANETARIUM_BEGGAR_VARIANT = 3102

Astro:AddCallback(
    ModCallbacks.MC_PRE_PLAYER_COLLISION,
    ---@param player EntityPlayer
    ---@param collider Entity
    ---@param low boolean
    function(_, player, collider, low)
        if collider.Type == EntityType.ENTITY_SLOT and collider.Variant == PLANETARIUM_BEGGAR_VARIANT then
            if player:GetNumCoins() < PRICE then
                return nil
            end

            local sprite = collider:GetSprite()

            if not sprite:IsPlaying("Idle") then
                return nil
            end

            SFXManager():Play(SoundEffect.SOUND_SCAMPER)

            player:AddCoins(-PRICE)

            local rng = player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_APOLLYON_B)

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
        if slot.Variant == 4 or slot.Variant == 5 or slot.Variant == 7 or slot.Variant == 9 or slot.Variant == 13 or slot.Variant == 18 then
            local room = Game():GetRoom()

            if room:GetType() == RoomType.ROOM_PLANETARIUM and slot.Variant ~= PLANETARIUM_BEGGAR_VARIANT then
                Isaac.Spawn(EntityType.ENTITY_SLOT, PLANETARIUM_BEGGAR_VARIANT, 0, slot.Position, Vector(0, 0), nil)
                slot:Remove()
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)        
        slot.SpriteOffset = Vector(0, 5)
    end,
    PLANETARIUM_BEGGAR_VARIANT
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_UPDATE,
    ---@param slot Entity
    function(_, slot)
        local sprite = slot:GetSprite()

        if sprite:IsFinished("PayPrize") then
            sprite:Play("Prize")
        elseif sprite:IsFinished("PayNothing") then
            sprite:Play("Idle")
        elseif sprite:IsFinished("Prize") then
            sprite:Play('Teleport')
        elseif sprite:IsFinished("Teleport") then
            slot:Remove()
        end

        if sprite:IsEventTriggered("Prize") then
            SFXManager():Play(SoundEffect.SOUND_THUMBSUP, 1)

            local itemPool = Game():GetItemPool()
            local item = itemPool:GetCollectible(ItemPoolType.POOL_PLANETARIUM, true)

            Astro:SpawnCollectible(item, slot.Position + Vector(0, 40))
        end

        if slot.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER then
            Game():GetLevel():SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)

            slot:BloodExplode()
            slot:Remove()
        end
    end,
    PLANETARIUM_BEGGAR_VARIANT
)

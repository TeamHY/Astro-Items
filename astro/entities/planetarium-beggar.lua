---

-- 성공 확률 (0 ~ 1)
local SUCCESS_CHANCE = 0.25

-- 가격
local PRICE = 1

---

local isc = require("astro.lib.isaacscript-common")

local PLANETARIUM_BEGGAR_VARIANT = 3102

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            EID:addEntity(
                EntityType.ENTITY_SLOT, PLANETARIUM_BEGGAR_VARIANT, 0,
                "천체관 거지",
                "{{Planetarium}} 동전 " .. PRICE .. "원을 기부하여 확률적으로 천체관 아이템 1개를 드롭합니다.",
                "ko_kr"
            )

            EID:addEntity(
                EntityType.ENTITY_SLOT, PLANETARIUM_BEGGAR_VARIANT, 0,
                "Platnetarium Beggar",
                "{{Planetarium}} Donate " .. PRICE .. " coins to have a chance to drop 1 Planetarium item.",
                "en_us"
            )
        end
    end
)

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
                sprite:Play("PayPrize", true)

                local data = collider:GetData()
                data.player = player
            else
                sprite:Play("PayNothing", true)
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
        
        --[[ 스폰 효과 쓸거면 쓰고 안쓸거면 말고
        local save = Astro.SaveManager.GetRunSave()
        local slotIndex = Astro.SaveManager.Utility.GetSaveIndex(slot)
        save._ASTRO_PLANETARIUM_BEGGAR_spawned = save._ASTRO_PLANETARIUM_BEGGAR_spawned or {}

        if not save._ASTRO_PLANETARIUM_BEGGAR_spawned[slotIndex] then
            Game():SpawnParticles(slot.Position + Vector(0, 3), 16, 1, 0, Color(0, 0, 0, 1, 0, 0.75, 1), nil, 66)
            Game():SpawnParticles(slot.Position + Vector(0, 3), 16, 1, 0, Color(0, 0, 0, 1, 0, 0.15, 0.33), nil, 66)
            save._ASTRO_PLANETARIUM_BEGGAR_spawned[slotIndex] = true
        end]]
    end,
    PLANETARIUM_BEGGAR_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        local slots = Isaac.FindByType(EntityType.ENTITY_SLOT, PLANETARIUM_BEGGAR_VARIANT, -1, true)
        if #slots > 0 then
            for _, slot in ipairs(slots) do
                slot.SpriteOffset = Vector(0, 5)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_UPDATE,
    ---@param slot Entity
    function(_, slot)
        slot.SpriteOffset = Vector(0, 5)
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

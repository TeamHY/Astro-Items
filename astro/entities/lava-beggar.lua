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

Astro.Entity.LAVA_BEGGAR = {
    Type = EntityType.ENTITY_SLOT,
    Variant = 3101,
    SubType = 0,
}

local LAVA_BEGGAR_VARIANT = Astro.Entity.LAVA_BEGGAR.Variant

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            EID:addEntity(
                EntityType.ENTITY_SLOT, LAVA_BEGGAR_VARIANT, 0,
                "용암 거지",
                "{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} 동전 " .. PRICE .. "원을 기부하여 소지중인 장신구를 모두 흡수합니다.",
                "ko_kr"
            )

            EID:addEntity(
                EntityType.ENTITY_SLOT, LAVA_BEGGAR_VARIANT, 0,
                "Lava Beggar",
                "{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Donate " .. PRICE .. " coins to absorb all trinkets you are holding.",
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
        if Astro.IsFight and Astro:HasCollectible(CollectibleType.COLLECTIBLE_DARK_BUM) then
            return
        end

        if slot.SubType == 0 and Game():GetRoom():GetType() ~= RoomType.ROOM_PLANETARIUM then
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

        --[[ 스폰 효과 쓸거면 쓰고 안쓸거면 말고
        local save = Astro.SaveManager.GetRunSave()
        local slotIndex = Astro.SaveManager.Utility.GetSaveIndex(slot)
        save._ASTRO_LAVA_BEGGAR_spawned = save._ASTRO_LAVA_BEGGAR_spawned or {}

        if not save._ASTRO_LAVA_BEGGAR_spawned[slotIndex] then
            Game():SpawnParticles(slot.Position + Vector(0, 3), 16, 2, 0, nil, nil, 66)
            save._ASTRO_LAVA_BEGGAR_spawned[slotIndex] = true
        end]]
    end,
    LAVA_BEGGAR_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        local slots = Isaac.FindByType(EntityType.ENTITY_SLOT, LAVA_BEGGAR_VARIANT, -1, true)
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
            sprite:Play("Idle")
        end
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
            slot:Remove()
        end
    end,
    LAVA_BEGGAR_VARIANT
)

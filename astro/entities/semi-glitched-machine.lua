---

local CHANGE_CHANCE = 1

local NO_FIGHT_CHANCE = 0.3

local PRICE = 10

local RUNE_COUNT = 1

---

local isc = require("astro.lib.isaacscript-common")

Astro.Entity.SemiGlitchedMachine = {
    Type = EntityType.ENTITY_SLOT,
    Variant = 3104,
    SubType = 1,
}

local INIT_CHECK_SUBTYPE = 1000

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            EID:addEntity(
                Astro.Entity.SemiGlitchedMachine.Type, Astro.Entity.SemiGlitchedMachine.Variant, Astro.Entity.SemiGlitchedMachine.SubType,
                "세미 글리치 머신",
                "{{Collectible" .. CollectibleType.COLLECTIBLE_GLITCHED_CROWN .. "}} 동전 " .. PRICE .. "원을 소모하여 파괴되며, 소울 오브 아이작을 " .. RUNE_COUNT .. "회 발동합니다.",
                "ko_kr"
            )

            EID:addEntity(
                Astro.Entity.SemiGlitchedMachine.Type, Astro.Entity.SemiGlitchedMachine.Variant, Astro.Entity.SemiGlitchedMachine.SubType,
                "Semi Glitched Machine",
                "{{Collectible" .. CollectibleType.COLLECTIBLE_GLITCHED_CROWN .. "}} Insert " .. PRICE .. " coin to destroy and activate Soul of Isaac " .. RUNE_COUNT .. " time(s).",
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
        if collider.Type == EntityType.ENTITY_SLOT and collider.Variant == Astro.Entity.SemiGlitchedMachine.Variant and collider.SubType == Astro.Entity.SemiGlitchedMachine.SubType then
            if player:GetNumCoins() < PRICE then
                return nil
            end

            local sprite = collider:GetSprite()

            if sprite:GetAnimation() ~= "Idle" then
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
        local level = Game():GetLevel()
        local room = Game():GetRoom()

        if level:GetStage() > LevelStage.STAGE1_2 or level:IsAltStage() then
            return
        end

        if room:GetType() ~= RoomType.ROOM_BOSS then
            return
        end

        local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_EVE)
        local chance = Astro.IsFight and CHANGE_CHANCE or NO_FIGHT_CHANCE

        if slot.SubType ~= INIT_CHECK_SUBTYPE and rng:RandomFloat() < chance then
            slot:Remove()
            Isaac.Spawn(EntityType.ENTITY_SLOT, Astro.Entity.SemiGlitchedMachine.Variant, Astro.Entity.SemiGlitchedMachine.SubType, slot.Position, Vector(0, 0), nil)
        elseif slot.SubType ~= INIT_CHECK_SUBTYPE then
            slot.SubType = INIT_CHECK_SUBTYPE
        end
    end,
    10
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_UPDATE,
    ---@param slot Entity
    function(_, slot)
        if slot.SubType ~= Astro.Entity.SemiGlitchedMachine.SubType then
            return
        end

        local sprite = slot:GetSprite()
        local entData = slot:GetData()

        if sprite:IsFinished("Initiate") then
            sprite:Play("Glitching")
        elseif sprite:IsFinished("Glitching") then
            sprite:Play("Death")
        elseif sprite:IsFinished("Death") then
            sprite:Play("Broken")
            slot.GridCollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
            slot:TakeDamage(1, DamageFlag.DAMAGE_EXPLOSION, EntityRef(slot), 0)
        end

        if sprite:IsEventTriggered("Explosion") then
            local player = Isaac.GetPlayer()

            for _ = 1, RUNE_COUNT do
                player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, slot.Position, Vector(0, 0), nil)
            SFXManager():Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS, 1)
        end

        if sprite:IsPlaying("Broken") then
            if not entData.EID_Hide then
                entData.EID_Hide = true
            end
        end

        if slot.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER then
            sprite:Play("Broken")
            slot:TakeDamage(1, DamageFlag.DAMAGE_EXPLOSION, EntityRef(slot), 0)
        end
    end,
    Astro.Entity.SemiGlitchedMachine.Variant
)

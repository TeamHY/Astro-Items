---

local CHANGE_CHANCE = 0.7

---

local isc = require("astro.lib.isaacscript-common")

---@param priceType number
---@param collectible CollectibleType
local function GetSubType(priceType, collectible)
    return priceType * 10000 + collectible
end

---@param subType number
local function GetData(subType)
    local priceType = subType // 10000

    local price = 10

    if priceType == 0 then
        price = 10
    elseif priceType == 1 then
        price = 15
    elseif priceType == 2 then
        price = 20
    elseif priceType == 3 then
        price = 25
    end

    return {
        price = price,
        priceType = priceType,
        collectible = subType % 10000
    }
end

Astro:AddCallback(
    ModCallbacks.MC_PRE_PLAYER_COLLISION,
    ---@param player EntityPlayer
    ---@param collider Entity
    ---@param low boolean
    function(_, player, collider, low)
        if collider.Type == EntityType.ENTITY_SLOT and collider.Variant == 3100 then
            local data = GetData(collider.SubType)

            if player:GetNumCoins() < data.price then
                return nil
            end

            local sprite = collider:GetSprite()

            if
                not (sprite:IsPlaying("Idle_10") or sprite:IsPlaying("Idle_15") or sprite:IsPlaying("Idle_20") or
                    sprite:IsPlaying("Idle_25"))
             then
                return nil
            end

            sprite:PlayOverlay("CoinInsert", true)
            SFXManager():Play(SoundEffect.SOUND_COIN_SLOT)

            local rng = player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_CAIN)

            if not (player:HasCollectible(Astro.Collectible.BIRTHRIGHT_CAIN) and rng:RandomFloat() < Astro.BIRTHRIGHT_CAIN_CHANCE) then
                player:AddCoins(-data.price)
            end

            sprite:Play("Initiate")
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)
        local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_EVE)

        if rng:RandomFloat() < CHANGE_CHANCE then
            local itemPool = Game():GetItemPool()
            local collectible = itemPool:GetCollectible(ItemPoolType.POOL_SHOP, true)

            slot:Remove()
            Isaac.Spawn(EntityType.ENTITY_SLOT, 3100, GetSubType(rng:RandomInt(4), collectible), slot.Position, Vector(0, 0), nil)
        end
    end,
    16
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)
        local data = GetData(slot.SubType)
        local collectible = data.collectible

        local itemConfig = Isaac.GetItemConfig():GetCollectible(collectible)
        local sprite = slot:GetSprite()

        sprite:ReplaceSpritesheet(2, itemConfig.GfxFileName)
        sprite:LoadGraphics()

        if data.priceType == 0 then
            sprite:Play("Idle_10")
        elseif data.priceType == 1 then
            sprite:Play("Idle_15")
        elseif data.priceType == 2 then
            sprite:Play("Idle_20")
        elseif data.priceType == 3 then
            sprite:Play("Idle_25")
        end
    end,
    3100
)

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

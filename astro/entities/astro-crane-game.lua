---

local CHANGE_CHANCE = 0.7

---

local isc = require("astro.lib.isaacscript-common")

local INIT_CHECK_SUBTYPE = 1000

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

------ 사왈 수정
Astro.EID.AstroCraneTarget = {}

local function AstroCraneModifierCondition(descObj)
    return descObj.ObjType == 6 and descObj.ObjVariant == 3100
end 

local function AstroCraneModifierCallback(descObj)
    local entity = descObj.Entity
    if entity then
        local sprite = entity:GetSprite()
        
        if sprite:IsPlaying("Broken") then
            return descObj
        end

        local craneItem = Astro.EID.AstroCraneTarget[tostring(entity.InitSeed)]

        if craneItem then
            local itemDesc = EID:getDescriptionObj(5, 100, craneItem)

            descObj = itemDesc
            return descObj
        end
    end
    return descObj
end

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            EID:addEntity(6, 3100, -1, "아스트로 크레인 게임", "동전 10~25개로 {{Shop}}상점 배열 아이템 1개를 드랍합니다.", "ko_kr")
            EID:addEntity(6, 3100, -1, "Astro Crane Game", "Drops one item from the {{Shop}}shop pool for 10~25 coins", "en_us")
            EID:addDescriptionModifier("Astro Crane Modifier", AstroCraneModifierCondition, AstroCraneModifierCallback)
        end
    end
)
------

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

            sprite:Play("Initiate", true)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)
        local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_EVE)

        if slot.SubType ~= INIT_CHECK_SUBTYPE and rng:RandomFloat() < CHANGE_CHANCE then
            local itemPool = Game():GetItemPool()
            local collectible = itemPool:GetCollectible(ItemPoolType.POOL_SHOP, true)

            slot:Remove()
            Isaac.Spawn(EntityType.ENTITY_SLOT, 3100, GetSubType(rng:RandomInt(4) * 10000, collectible), slot.Position, Vector(0, 0), nil)
        elseif slot.SubType ~= INIT_CHECK_SUBTYPE then
            slot.SubType = INIT_CHECK_SUBTYPE
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

        if EID then
            local seed = tostring(slot.InitSeed)
            Astro.EID.AstroCraneTarget[seed] = collectible
        end
    end,
    3100
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_UPDATE,
    ---@param slot Entity
    function(_, slot)
        local sprite = slot:GetSprite()
        local entData = slot:GetData()

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
        end

        if sprite:IsEventTriggered("Explosion") then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, slot.Position, Vector(0, 0), nil)
        end

        if sprite:IsEventTriggered("Prize") then
            local data = GetData(slot.SubType)
            Astro:SpawnCollectible(data.collectible, slot.Position)
            data.EID_Hide = nil
        end

        if sprite:IsPlaying("Broken") then
            if not entData.EID_Hide then
                entData.EID_Hide = true
                Astro.EID.AstroCraneTarget[tostring(slot.InitSeed)] = nil
            end
        elseif entData.EID_Hide then
            entData.EID_Hide = nil
        end

        if slot.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER then
            sprite:Play("Broken")
        end
    end,
    3100
)
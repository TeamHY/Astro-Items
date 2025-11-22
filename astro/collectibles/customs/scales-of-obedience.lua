---

Astro.Collectible.SCALES_OF_OBEDIENCE = Isaac.GetItemIdByName("Scales of Obedience")

local ITEM_ID = Astro.Collectible.SCALES_OF_OBEDIENCE

local EFFECT_OFFSET = Vector(0, -30)

---

local SCALES_OF_OBEDIENCE_VARIANT = Isaac.GetEntityVariantByName("Scales of Obedience")

if EID then
    Astro:AddEIDCollectible(
        ITEM_ID,
        "복종의 천칭",
        "↑ {{ColorCyan}}모든 세트 적용{{CR}}" ..
        "#공격력이 적의 체력보다 높으면 해당 적을 지웁니다. (보스에겐 미적용)"
    )

    Astro:AddEIDCollectible(
        ITEM_ID,
        "Scales of Obedience",
        "",
        "Activates all set effects." ..
        "#Erases monsters if your damage exceeds their hit points. Does not work on boss monsters.",
        nil,
        "en_us"
    )
end

Astro:AddUpgradeAction(
    function(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            local targets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_LIBRA, true, false)
            
            if #targets < 1 then
                return nil
            end

            return {
                targets = targets
            }
        end

        return nil
    end,
    function(player, data)
        for _, target in ipairs(data.targets) do
            target:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
            
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, target.Position, target.Velocity, nil)
            SFXManager():Play(Astro.SoundEffect.SCALES_OF_OBEDIENCE_APPEAR)

            player:RemoveCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE, true)
            player:AnimateCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local maxDamage = 0

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(ITEM_ID) then
                maxDamage = math.max(maxDamage, player.Damage)
            end
        end

        if maxDamage == 0 then
            return
        end

        local entities = Isaac.GetRoomEntities()
            
        for _, entity in ipairs(entities) do
            local npc = entity:ToNPC()

            if not npc or npc:IsBoss() or not npc:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
                goto continue
            end

            if npc.HitPoints <= maxDamage then
                Isaac.Spawn(
                    EntityType.ENTITY_TEAR,
                    TearVariant.ERASER,
                    0,
                    npc.Position,
                    Vector.Zero,
                    nil
                )
            end

            ::continue::
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    ---@param npc EntityNPC
    function(_, npc)
        if not npc:IsBoss() and npc:IsVulnerableEnemy() and npc.Type ~= EntityType.ENTITY_FIREPLACE then
            local maxDamage = 0

            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
            
                if player:HasCollectible(ITEM_ID) then
                    maxDamage = math.max(maxDamage, player.Damage)
                end
            end

            if maxDamage ~= 0 and npc.HitPoints <= maxDamage then
                Isaac.Spawn(
                    EntityType.ENTITY_TEAR,
                    TearVariant.ERASER,
                    0,
                    npc.Position,
                    Vector.Zero,
                    nil
                )
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if effect.Parent ~= nil then
            local position = effect.Parent.Position + Vector(0, 10)
            effect.Position = position
            effect.Velocity = effect.Parent.Velocity
        end
    end,
    SCALES_OF_OBEDIENCE_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(ITEM_ID) then
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, SCALES_OF_OBEDIENCE_VARIANT, 0, player.Position, Vector.Zero, nil)
                effect.Parent = player
                effect:GetSprite().Offset = EFFECT_OFFSET
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    ---@param pickup EntityPickup
    function(_, pickup)
        if pickup.SubType == CollectibleType.COLLECTIBLE_LIBRA then
            local blues = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, -1, true, false)
            
            for _, effect in ipairs(blues) do
                if Astro:CheckOverlap(effect, pickup) then
                    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
                    
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, pickup.Position, pickup.Velocity, nil)
                    SFXManager():Play(Astro.SoundEffect.SCALES_OF_OBEDIENCE_APPEAR)
                    return
                end
            end

            local reds = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, -1, true, false)

            for _, effect in ipairs(reds) do
                if Astro:CheckOverlap(effect, pickup) then
                    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
                    
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, pickup.Position, pickup.Velocity, nil)
                    SFXManager():Play(Astro.SoundEffect.SCALES_OF_OBEDIENCE_APPEAR)
                    return
                end
            end
        end
    end,
    PickupVariant.PICKUP_COLLECTIBLE
)

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_PRE_ADD_COLLECTIBLE,
        ---@param type CollectibleType
        ---@param charge integer
        ---@param firstTime boolean
        ---@param slot integer
        ---@param varData integer
        ---@param player EntityPlayer
        function(_, type, charge, firstTime, slot, varData, player)
            if type ~= ITEM_ID then
                return
            end

            if not player:HasCollectible(ITEM_ID) then
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, SCALES_OF_OBEDIENCE_VARIANT, 0, player.Position, Vector.Zero, nil)
                effect.Parent = player
                effect:GetSprite().Offset = EFFECT_OFFSET
            end
        end
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_ADD_COLLECTIBLE,
        ---@param type CollectibleType
        ---@param charge integer
        ---@param firstTime boolean
        ---@param slot integer
        ---@param varData integer
        ---@param player EntityPlayer
        function(_, type, charge, firstTime, slot, varData, player)
            if type ~= ITEM_ID then
                return
            end
            
            if not firstTime then
                return
            end

            for i = 0, PlayerForm.NUM_PLAYER_FORMS - 1 do
                player:IncrementPlayerFormCounter(i, 3)
            end
        end
    )
end

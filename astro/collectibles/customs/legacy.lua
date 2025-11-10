---

Astro.Collectible.LEGACY = Isaac.GetItemIdByName("Legacy")

local ITEM_ID = Astro.Collectible.LEGACY

local USE_KEY = Keyboard.KEY_7

local USE_SOUND_VOLUME = 1.0

---

if EID then
    Astro:AddEIDCollectible(
        ITEM_ID,
        "유산",
        "...",
        "숫자 7키를 누르면 스테이지당 한번;" ..
        "{{ArrowGrayRight}} 방 안의 모든 아이템을 아무 변신세트 아이템으로 바꿉니다." .. 
        "모든 변신세트의 효과가 강화됩니다." ..
        "{{ColorGray}} (Bookworm 효과 미구현)"
    )

    Astro:AddEIDCollectible2(
        "en_us",
        ITEM_ID,
        "Legacy", 
        "Press 7 to transform all items in the room into random set items. Can only be used once per floor." ..
        "All transformation effects are enhanced." ..
        "{{ColorGray}} Bookworm effect not implemented"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        if not Input.IsButtonTriggered(USE_KEY, 0) then
            return
        end

        local data = Astro.SaveManager.GetFloorSave()

        if data["legacyActive"] then
            return
        end

        local player = nil ---@type EntityPlayer?

        for i = 1, Game():GetNumPlayers() do
            local p = Isaac.GetPlayer(i - 1)

            if p:HasCollectible(ITEM_ID) then
                player = p
                break
            end
        end

        if not player then
            return
        end

        local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true)

        if #items == 0 then
            return
        end

        local rng = player:GetCollectibleRNG(ITEM_ID)

        for _, item in ipairs(items) do
            local pickup = item:ToPickup() ---@cast pickup EntityPickup

            local randomIndex = rng:RandomInt(#Astro.SetsCollectibles) + 1
            local newCollectible = Astro.SetsCollectibles[randomIndex]

            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newCollectible, true, true, false)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, pickup.Position, Vector.Zero, nil)
            SFXManager():Play(Astro.SoundEffect.LEGACY_USE, USE_SOUND_VOLUME)
            player:AnimateCollectible(ITEM_ID)
        end

        data["legacyActive"] = true
    end
)

---@param player EntityPlayer
local function GetSetsCount(player)
    local count = 0

    for _, collectibleId in ipairs(Astro.SetsCollectibles) do
        count = count + player:GetCollectibleNum(collectibleId)
    end

    return count
end

---@param player EntityPlayer
---@param form PlayerForm
local function ShouldEnhance(player, form)
    return player:HasCollectible(ITEM_ID) and player:HasPlayerForm(form)
end

Astro:AddUpgradeAction(
    function(player)
        if GetSetsCount(player) >= 6 then
            local targets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_BIRTHRIGHT, true, false)

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
            SFXManager():Play(Astro.SoundEffect.LEGACY_APPEAR)

            -- player:RemoveCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE, true)
            -- player:AnimateCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)
        end
    end
)

local function CheckAngelTime()
    return Game():GetFrameCount() % (40 * 30) < (20 * 30)
end

--#region Guppy
local FLY_SUBTYPE = 1000

Astro:AddCallback(
    Astro.Callbacks.SPAWNED_BLUE_FLY,
    ---@param fly EntityFamiliar
    function(_, fly)
        local player = fly.Player

        if not ShouldEnhance(player, PlayerForm.PLAYERFORM_GUPPY) then
            return
        end

        Isaac.Spawn(
            EntityType.ENTITY_FAMILIAR,
            FamiliarVariant.BLUE_FLY,
            FLY_SUBTYPE,
            fly.Position,
            Vector.Zero,
            player
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        local shouldEnhance = false

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if ShouldEnhance(player, PlayerForm.PLAYERFORM_GUPPY) then
                shouldEnhance = true
            end
        end

        if not shouldEnhance then
            return
        end

        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, -1, -1, true)) do
            if entity.Variant == FamiliarVariant.BLUE_FLY then
                entity:Update()
            end
        end
    end
)
--#endregion

--#region Lord of The Flies
Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if ShouldEnhance(player, PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES) then
            Astro.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_HIVE_MIND, 1, "HY_PACK_LEGACY")
        end
    end
)
--#endregion

--#region Mushroom
Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()

        if player and ShouldEnhance(player, PlayerForm.PLAYERFORM_MUSHROOM) then
            tear:AddTearFlags(TearFlags.TEAR_STICKY)
        end
    end
)
--#endregion

--#region Angel
local ANGEL_DAMAGE_MULTIPLIER = 1.2

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(ITEM_ID) then
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 3110, 0, player.Position, Vector.Zero, nil)
                effect.Parent = player
                effect.Visible = false
            end
        end
    end
)

if REPENTOGON then
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
            
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 3110, 0, player.Position, Vector.Zero, nil)
            effect.Parent = player
            effect.Visible = false
        end
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if effect.SubType == 0 and effect.Parent ~= nil then
            local player = effect.Parent:ToPlayer()

            if not player then
                return
            end

            local sprite = effect:GetSprite()
            local currentAnimation = sprite:GetAnimation()

            if CheckAngelTime() and ShouldEnhance(player, PlayerForm.PLAYERFORM_ANGEL) then
                if currentAnimation ~= "Open" and currentAnimation ~= "Idle" then
                    sprite:Play("Open", true)
                    effect.Visible = true

                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end

                if sprite:IsFinished("Open") then
                    sprite:Play("Idle", true)
                end
            else
                if currentAnimation ~= "Close" then
                    sprite:Play("Close", true)

                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end

                if sprite:IsFinished("Close") then
                    effect.Visible = false
                end
            end

            if effect.Visible then
                local position = player.Position + Vector(0, 2)
                effect.Position = position
                effect.Velocity = player.Velocity
            end
        end
    end,
    3110
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if not ShouldEnhance(player, PlayerForm.PLAYERFORM_ANGEL) then
            return
        end

        if CheckAngelTime() then
            player.Damage = player.Damage * ANGEL_DAMAGE_MULTIPLIER
        end
    end,
    CacheFlag.CACHE_DAMAGE
)
--#endregion

--#region Bob
Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if ShouldEnhance(player, PlayerForm.PLAYERFORM_BOB) then
            Astro.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_HOST_HAT, 1, "HY_PACK_LEGACY")
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()

        if player and ShouldEnhance(player, PlayerForm.PLAYERFORM_BOB) then
            tear:ChangeVariant(TearVariant.BOBS_HEAD)
        end
    end
)
--#endregion

--#region Drugs
local function CheckNeedleChance(player)
    local rng = player:GetCollectibleRNG(ITEM_ID)
    local denominator = 30 - math.floor(player.Luck * 2)
    local chance = denominator <= 0 and 1 or (1 / denominator)
    
    return rng:RandomFloat() < chance
end

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)

        if player ~= nil and ShouldEnhance(player, PlayerForm.PLAYERFORM_DRUGS) and player:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then
            if CheckNeedleChance(player) then
                if not tear:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                    tear:ChangeVariant(TearVariant.NEEDLE)
                    tear:AddTearFlags(TearFlags.TEAR_NEEDLE)
                    tear.CollisionDamage = tear.CollisionDamage * 3
                end
            elseif tear:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                tear:ClearTearFlags(TearFlags.TEAR_NEEDLE)
                tear:ChangeVariant(TearVariant.BLUE)
                tear.CollisionDamage = tear.CollisionDamage / 3
            end
        end
    end
)

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_TECH_LASER,
        ---@param laser EntityLaser
        function(_, laser)
            local player = Astro:GetPlayerFromEntity(laser)
            
            if player ~= nil and ShouldEnhance(player, PlayerForm.PLAYERFORM_DRUGS) and player:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then
                if CheckNeedleChance(player) then
                    if not laser:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                        laser:AddTearFlags(TearFlags.TEAR_NEEDLE)
                        laser.CollisionDamage = laser.CollisionDamage * 3
                    end
                elseif laser:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                    laser:ClearTearFlags(TearFlags.TEAR_NEEDLE)
                    laser.CollisionDamage = laser.CollisionDamage / 3
                end
            end
        end
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_TECH_X_LASER,
        ---@param laser EntityLaser
        function(_, laser)
            local player = Astro:GetPlayerFromEntity(laser)

            if player ~= nil and ShouldEnhance(player, PlayerForm.PLAYERFORM_DRUGS) and player:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then
                if CheckNeedleChance(player) then
                    if not laser:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                        laser:AddTearFlags(TearFlags.TEAR_NEEDLE)
                        laser.CollisionDamage = laser.CollisionDamage * 3
                    end
                elseif laser:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                    laser:ClearTearFlags(TearFlags.TEAR_NEEDLE)
                    laser.CollisionDamage = laser.CollisionDamage / 3
                end
            end
        end
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL,
        ---@param laser EntityLaser
        function(_, laser)
            local player = Astro:GetPlayerFromEntity(laser)

            if player ~= nil and ShouldEnhance(player, PlayerForm.PLAYERFORM_DRUGS) and player:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then
                if CheckNeedleChance(player) then
                    if not laser:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                        laser:AddTearFlags(TearFlags.TEAR_NEEDLE)
                        laser.CollisionDamage = laser.CollisionDamage * 3
                    end
                elseif laser:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                    laser:ClearTearFlags(TearFlags.TEAR_NEEDLE)
                    laser.CollisionDamage = laser.CollisionDamage / 3
                end
            end
        end
    )
    
    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_SWORD,
        ---@param knife EntityKnife
        function(_, knife)
            local player = Astro:GetPlayerFromEntity(knife)
            
            if player ~= nil and ShouldEnhance(player, PlayerForm.PLAYERFORM_DRUGS) and player:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then
                if CheckNeedleChance(player) then
                    if not knife:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                        knife:AddTearFlags(TearFlags.TEAR_NEEDLE)
                        knife.CollisionDamage = knife.CollisionDamage * 3
                    end
                elseif knife:HasTearFlags(TearFlags.TEAR_NEEDLE) then
                    knife:ClearTearFlags(TearFlags.TEAR_NEEDLE)
                    knife.CollisionDamage = knife.CollisionDamage / 3
                end
            end
        end
    )
end
--#endregion

--#region Mom
Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if pickup.Variant == PickupVariant.PICKUP_PILL then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if ShouldEnhance(player, PlayerForm.PLAYERFORM_MOM) then
                    Game():GetItemPool():IdentifyPill(pickup.SubType)
                    break
                end
            end
        end
    end
)
--#endregion

--#region Baby
Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()

        if player and ShouldEnhance(player, PlayerForm.PLAYERFORM_BABY) then
            tear:AddTearFlags(TearFlags.TEAR_TURN_HORIZONTAL)
        end
    end
)
--#endregion

--#region Evil Angel
local EVIL_ANGEL_DAMAGE_BONUS = 0.2

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(ITEM_ID) then
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 3110, 1, player.Position, Vector.Zero, nil)
                effect.Parent = player
                effect.Visible = false
            end
        end
    end
)

if REPENTOGON then
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
            
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 3110, 1, player.Position, Vector.Zero, nil)
            effect.Parent = player
            effect.Visible = false
        end
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if effect.SubType == 1 and effect.Parent ~= nil then
            local player = effect.Parent:ToPlayer()

            if not player then
                return
            end

            local sprite = effect:GetSprite()
            local currentAnimation = sprite:GetAnimation()

            if not CheckAngelTime() and ShouldEnhance(player, PlayerForm.PLAYERFORM_EVIL_ANGEL) then
                if currentAnimation ~= "Open" and currentAnimation ~= "Idle" then
                    sprite:Play("Open", true)
                    effect.Visible = true
                end

                if sprite:IsFinished("Open") then
                    sprite:Play("Idle", true)
                end
            else
                if currentAnimation ~= "Close" then
                    sprite:Play("Close", true)
                end

                if sprite:IsFinished("Close") then
                    effect.Visible = false
                end
            end

            if effect.Visible then
                local position = player.Position + Vector(0, 2)
                effect.Position = position
                effect.Velocity = player.Velocity
            end
        end
    end,
    3110
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and not CheckAngelTime() and ShouldEnhance(player, PlayerForm.PLAYERFORM_EVIL_ANGEL) then
            if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and (source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE) then
                entity:TakeDamage(amount * EVIL_ANGEL_DAMAGE_BONUS, 0, EntityRef(player), 0)
            end
        end
    end
)
--#endregion

--#region Poop
local POOP_COOLDOWN_TIME = 300
local POOP_MIN_COOLDOWN_TIME = 300

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if ShouldEnhance(player, PlayerForm.PLAYERFORM_POOP) then
                local data = Astro.SaveManager.GetRunSave(player)

                if data["legacyPoop"] == nil then
                    data["legacyPoop"] = {
                        NextFrameCount = 0
                    }
                end

                local frameCount = Game():GetFrameCount()

                if data["legacyPoop"].NextFrameCount <= frameCount then
                    local ibsCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IBS)
                    data["legacyPoop"].NextFrameCount = math.min(frameCount + POOP_COOLDOWN_TIME / (2 ^ (ibsCount - 1)), frameCount + POOP_MIN_COOLDOWN_TIME)

                    player:UsePoopSpell(PoopSpellType.SPELL_LIQUID)
                end
            end
        end
    end
)
--#endregion

--#region Book Worm
-- TODO: 더블샷
--#endregion

--#region Spider Baby
local SPIDER_SPAWN_CHANCE = 0.5

Astro:AddCallback(
    Astro.Callbacks.PLAYER_DEAL_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param player EntityPlayer
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, player, countdownFrames)
        if ShouldEnhance(player, PlayerForm.PLAYERFORM_SPIDERBABY) then
            local rng = player:GetCollectibleRNG(ITEM_ID)

            if rng:RandomFloat() < SPIDER_SPAWN_CHANCE then
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, 0, player.Position, Vector.Zero, player)
            end
        end
    end
)
--#endregion

--#region Stompy
Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if ShouldEnhance(player, PlayerForm.PLAYERFORM_STOMPY) then
                player:UseCard(Card.RUNE_HAGALAZ, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                break
            end
        end
    end
)
--#endregion

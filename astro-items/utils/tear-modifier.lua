--TODO: I can't be bothered to discern which of these args are or aren't allowed to be unused, so I'm just disabling the check here for now
--luacheck: no unused args
local Mod = AstroItems
local game = Game()

function AstroItems:Delay2Tears(delay)
    return 30 / (delay + 1)
end

function AstroItems:Tears2Delay(tears)
    return (30 / tears) - 1
end

---@function
function AstroItems:Clamp(value, min, max)
	-- this is actually faster than math.min(math.max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

---@function
function AstroItems:Lerp(first, second, percent)
	return (first + (second - first) * percent)
end

--- Gives the player's luck accounting for teardrop charm
---@param player EntityPlayer
---@return integer
function AstroItems:GetTearModifierLuck(player)
	local luck = player.Luck
	if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
		luck = luck + (player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM) * 4)
	end
	return luck
end

---@class Cooldown
---@field Laser integer
---@field KnifeHit integer
---@field KnifeSwing integer
---@field Ludovico integer
---@field CSection integer

---@class TearModifier
---@field Name string @The string identifier for this TearModifier.
---@field Items CollectibleType[] @List of items that cause this TearModifier to activate.
---@field Trinkets TrinketType[] @List of trinkets that cause this TearModifier to activate.
---@field IsTrinket boolean @If `Item` is a `TrinketType`.
---@field MinLuck number @The minimum luck for calculating chance-based tear modifiers.
---@field MaxLuck number @The maximum luck for calculating chance-based tear modifiers.
---@field MinChance number @The minimum chance of proccing for chance-based tear modifiers. Affected by the luck variables.
---@field MaxChance number @The maximum chance of proccing for chance-based tear modifiers. Affected by the luck variables.
---@field LastRoll integer @The last chance roll made. Only set when using the default GetChance.
---@field ShouldAffectBombs boolean @Whether Dr and Epic fetus are affected by this modifier.
---@field Cooldown Cooldown
---@field GFX string? @The anm2 to use for the tear.
---@field Color Color? @The color to use for the tear.
local TearModifier = {}
TearModifier.__index = TearModifier


---Before an affected tear, bomb, knife, or laser collides with an entity. If not a laser, return "true" to cancel the collision, "false" to collide but not execute internal code, or nothing to pass.
---For performance reasons, when a laser this only activates for pickups, NPCs, and projectiles.
---Does not affect Epic Fetus.
---@param object EntityTear | EntityKnife | EntityLaser | EntityBomb
---@param collider Entity
---@param low boolean
function TearModifier:PreEntityCollision(object, collider, low)

end

---Before an affected tear, bomb, knife, or laser hits an NPC. `hitter` will be an EntityEffect if Epic Fetus.
---@param hitter EntityTear | EntityKnife | EntityLaser | EntityBomb | EntityEffect
---@param npc EntityNPC
---@param isKnifeSwing boolean? This will be true or nil. True means it came from a swinging knife, a la bone clubs.
---@param isSamsonPunch boolean? This will be true or nil. True means it was a Samson punch, and `hitter` is the player.
---@param isCainBag boolean? This will be true or nil. True means it was a Cain's bag, and `hitter` is the bag.
function TearModifier:PostNpcHit(hitter, npc, isKnifeSwing, isSamsonPunch, isCainBag)

end

---After an affected tear, knife, bomb, or laser collides with a grid entity. Called after but in the same frame as PostUpdate. Does not affect Epic Fetus.
---@param object EntityTear | EntityKnife | EntityLaser | EntityBomb
---@param collidePosition Vector
function TearModifier:PostGridCollision(object, collidePosition)

end

---After an affected tear, knife, bomb, or laser updates. Does not affect Epic Fetus.
---@param object EntityTear | EntityKnife | EntityLaser  | EntityBomb
function TearModifier:PostUpdate(object)

end

---After an affected tear, knife, bomb, or laser renders. Does not affect Epic Fetus.
---@param object EntityTear | EntityKnife | EntityLaser | EntityBomb
---@param renderOffset Vector
function TearModifier:PostRender(object, renderOffset)

end

---After an affected tear spawns, a laser fires, an Epic/Dr Fetus bomb fires, or a knife fires. Keep in mind that affected lasers and knives may not be affected for the rest of their lifespan.
---`object` is an EntityEffect if Epic Fetus.
---@param object EntityTear | EntityLaser | EntityKnife | EntityBomb | EntityEffect
function TearModifier:PostFire(object)

end

---After a Dr Fetus bomb explodes.
---Can't get it to work for Epic Fetus at this time.
---@param bomb EntityBomb
function TearModifier:PostExplode(bomb)

end

---Returns the RNG object for the item or trinket that causes this TearModifier to activate.
---Returns nil if the player doesn't have any items or trinkets that contribute to the tear modifier.
---@param player EntityPlayer
---@return RNG?
function TearModifier:TryGetItemRNG(player)
    for i=1, #self.Items do
        if player:HasCollectible(self.Items[i]) then
            return player:GetCollectibleRNG(self.Items[i])
        end
    end

    for i=1, #self.Trinkets do
        if player:HasTrinket(self.Trinkets[i], false) then
            return player:GetTrinketRNG(self.Trinkets[i])
        end
    end
end

---Only called for tears and bombs, this checks if the TearModifier should be applied.
---@param player EntityPlayer
function TearModifier:CheckTearAffected(player)
    local rng = self:TryGetItemRNG(player)

    return rng and rng:RandomFloat() < self:GetChance(player)
end

---Only called for knives, lasers, samson's punch, and Ludovico, this checks if the TearModifier should be applied.
---@param player EntityPlayer
---@param weapon EntityKnife | EntityLaser | EntityTear | nil Nil if a samson punch.
function TearModifier:CheckKnifeLaserAffected(player, weapon)
    local rng = self:TryGetItemRNG(player)
    if not rng then
        return false
    end

    local frameCount = weapon and weapon.FrameCount or 0

    if frameCount == 0 or frameCount % 6 == 0 then
        self.LastRoll = rng:RandomFloat()
    end

    return self.LastRoll < self:GetChance(player)
end

---A percentage float chance to be used with an RNG object.
---@param player EntityPlayer
function TearModifier:GetChance(player)
    local luck = Mod:GetTearModifierLuck(player)
	luck = Mod:Clamp(luck, self.MinLuck, self.MaxLuck)

	local deltaX = self.MaxLuck - self.MinLuck
	local rngRequirement = ((self.MaxChance - self.MinChance) / deltaX) * luck + (self.MaxLuck * self.MinChance - self.MinLuck * self.MaxChance) / deltaX

	return rngRequirement
end

---Checks and Adds a Cooldown to the modifier
---@param entity Entity
---@param addDelay integer
---@return boolean
function TearModifier:IsOnCooldown(entity, addDelay)
    local frame = game:GetFrameCount()
    if entity:GetData()["ASTRO_".. self.Name .. "_Frame"] and
    entity:GetData()["ASTRO_".. self.Name .. "_Frame"] > frame then
        return true
    end

    if addDelay then
        entity:GetData()["ASTRO_".. self.Name .. "_Frame"] = frame + addDelay
    end
    return false
end

---Prints the percentage chance the player would have at any given luck, with or without tear drop charm.
---@param luck number
---@param teardropCharm boolean @Act as if teardrop charm is enabled.
function TearModifier:PrintChanceLine(luck, teardropCharm)
	if teardropCharm then
		luck = luck + 3
	end
	luck = Mod:Clamp(luck, self.MinLuck, self.MaxLuck)

	local deltaX = self.MaxLuck - self.MinLuck
	local rngRequirement = ((self.MaxChance - self.MinChance) / deltaX) * luck + (self.MaxLuck * self.MinChance - self.MinLuck * self.MaxChance) / deltaX
    local luckString = teardropCharm and (tostring(luck - 3) .. " (+3 from teardrop charm)") or tostring(luck)

	-- Epiphany:DebugLog("The player has a " .. string.format("%.2f%%", rngRequirement * 100) .. " for the " .. self.Name .. " TearModifier to activate at " .. luckString .. " luck")
end

---Gets a player from a knife, laser, or tear, if one exists.
---@param hitter EntityKnife | EntityLaser | EntityTear | EntityPlayer
---@return EntityPlayer?
function TearModifier:GetPlayerFromHitter(hitter)
    if hitter:ToPlayer() then
        ---@cast hitter EntityPlayer
        return hitter
    end
    if not hitter.SpawnerEntity then
        return
    end

    return hitter.SpawnerEntity:ToFamiliar() and hitter.SpawnerEntity:ToFamiliar().Player or hitter.SpawnerEntity:ToPlayer()
end

---@class TearModifierParams
---@field Name string @The string identifier for this TearModifier.
---@field Items CollectibleType[]? @List of items that cause this TearModifier to activate.
---@field Trinkets TrinketType[]? @List of trinkets that cause this TearModifier to activate.
---@field MinLuck number? @The minimum luck for calculating chance-based tear modifiers. 0 by default.
---@field MaxLuck number? @The maximum luck for calculating chance-based tear modifiers. 10 by default.
---@field MinChance number? @The minimum chance of proccing for chance-based tear modifiers. Affected by the luck variables. 0 by default.
---@field MaxChance number? @The maximum chance of proccing for chance-based tear modifiers. Affected by the luck variables. 1 by default.
---@field GFX string? @The anm2 to use for a tear. Leave nil to let the game decide.
---@field Color Color? @The color to use for a tear, knife, or laser. Leave nil to let the game decide.
---@field ShouldAffectBombs boolean? @If Dr and Epic Fetus should be affected. By default, this is false.
---@field Cooldown Cooldown?
---Constructs a new TearModifier. Use this for deciding the luck stuff: https://www.desmos.com/calculator/b9x583q0md
---@param params TearModifierParams
---@return TearModifier
function TearModifier.New(params)
    local self = setmetatable({}, TearModifier)
    self.Name = params.Name or error('Field "Name" is required for TearModifier', 2)
    self.Items = params.Items or {}
    self.Trinkets = params.Trinkets or {}
    if #self.Items == 0 and #self.Trinkets == 0 then
        error('Both "Items" and "Trinkets" are empty', 2)
    end

    self.MinLuck = params.MinLuck or 0
    self.MaxLuck = params.MaxLuck or 10
    self.MinChance = params.MinChance or 0
    self.MaxChance = params.MaxChance or 0.25
    self.LastRoll = 0

    self.GFX = params.GFX
    self.Color = params.Color

    self.ShouldAffectBombs = params.ShouldAffectBombs or false

    local values = params.Cooldown
    self.Cooldown = {
        Laser = values and values.Laser or 3,
        KnifeHit = values and values.KnifeHit or 2,
        KnifeSwing = values and values.KnifeSwing or 4,
        Ludovico = values and values.Ludovico or 7,
        CSection = values and values.CSection or 6
    }

    --#region TEAR CODE
    ---@param tear EntityTear
    Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
        if not tear.SpawnerEntity or tear:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            return
        end

        local player = tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player or tear.SpawnerEntity:ToPlayer()
        if player and self:CheckTearAffected(player) then
            local sprite = tear:GetSprite()
            if self.GFX then
                sprite:Load(self.GFX, true)
                sprite:Play(sprite:GetDefaultAnimation(), true)
            end

            if self.Color then
                sprite.Color = self.Color
            end

            tear:GetData()["ASTRO_" .. self.Name] = true
            self:PostFire(tear)
        end
    end)

    --Ludo
    ---@param tear EntityTear
    Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function (_, tear)
        if not tear.SpawnerEntity or tear:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            return
        end

        if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
            local player = tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player or tear.SpawnerEntity:ToPlayer()
            if player and self:CheckKnifeLaserAffected(player, tear) then
                local sprite = tear:GetSprite()
                if self.Color then
                    sprite.Color = self.Color
                end

                tear:GetData()["ASTRO_" .. self.Name] = true
            elseif tear:GetData()["ASTRO_" .. self.Name] then
                tear:GetData()["ASTRO_" .. self.Name] = false
                tear:GetSprite().Color = Color.Default ---@diagnostic disable-line: undefined-field
            end
        end
    end)

    ---@param tear EntityTear
    Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
        if tear:GetData()["ASTRO_" .. self.Name] and not tear:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            self:PostUpdate(tear)

            if tear:CollidesWithGrid() then
                self:PostGridCollision(tear, tear.Position)
            end
        end

        if not tear:GetData()["ASTRO_" .. self.Name .. "_Disabled"] and tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
            local player = tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player or tear.SpawnerEntity:ToPlayer()
            if player and self:CheckKnifeLaserAffected(player, tear) then
                local sprite = tear:GetSprite()
                if self.Color then
                    sprite.Color = self.Color
                end

                tear:GetData()["ASTRO_" .. self.Name] = true
            elseif tear:GetData()["ASTRO_" .. self.Name] then
                tear:GetData()["ASTRO_" .. self.Name] = false
                tear:GetSprite().Color = Color.Default ---@diagnostic disable-line: undefined-field
            end
        end
    end)

    ---@param tear EntityTear
    ---@param offset Vector
    Mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, function (_, tear, offset)
        if tear:GetData()["ASTRO_" .. self.Name] and not tear:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            self:PostRender(tear, offset)
        end
    end)


    ---@param collider Entity
    Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function (_, tear, collider, low)
        if tear:GetData()["ASTRO_" .. self.Name] and not tear:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            if collider:ToNPC() and not collider:ToNPC():HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                -- I know it's ugly but the logic is making my brain melt
                local skip = false
                if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO)
                and self:IsOnCooldown(tear, self.Cooldown.Ludovico) then
                    skip = true
                end
                if tear:HasTearFlags(TearFlags.TEAR_FETUS)
                and self:IsOnCooldown(tear, self.Cooldown.CSection) then
                    skip = true
                end

                if not skip then
                    self:PostNpcHit(tear, collider:ToNPC())
                end
            end

            return self:PreEntityCollision(tear, collider, low)
        end
    end)
    --#endregion

    --#region KNIFE CODE
    ---@param knife EntityKnife
    Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function (_, knife)
        if not knife.SpawnerEntity or knife:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            return
        end

        local player = knife.SpawnerEntity:ToFamiliar() and knife.SpawnerEntity:ToFamiliar().Player or knife.SpawnerEntity:ToPlayer()
        if player and self:CheckKnifeLaserAffected(player, knife) then
            local sprite = knife:GetSprite()
            if self.Color then
                sprite.Color = self.Color
            end

            knife:GetData()["ASTRO_" .. self.Name] = true
            self:PostFire(knife)
        end
    end)

    ---@param knife EntityKnife
    Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function (_, knife)
        if not knife.SpawnerEntity or knife:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            return
        end

        local player = knife.SpawnerEntity:ToFamiliar() and knife.SpawnerEntity:ToFamiliar().Player or knife.SpawnerEntity:ToPlayer()
        if player and self:CheckKnifeLaserAffected(player, knife) then
            local sprite = knife:GetSprite()
            if self.Color then
                sprite.Color = self.Color
            end

            knife:GetData()["ASTRO_" .. self.Name] = true
        elseif knife:GetData()["ASTRO_" .. self.Name] then
            knife:GetData()["ASTRO_" .. self.Name] = false
            knife:GetSprite().Color = Color.Default ---@diagnostic disable-line: undefined-field
        end

        if knife:GetData()["ASTRO_" .. self.Name] then
            self:PostUpdate(knife)

            if knife:CollidesWithGrid() then
                self:PostGridCollision(knife, knife.Position)
            end

            knife:GetData().ASTRO_EntityCollisionMap = knife:GetData().ASTRO_EntityCollisionMap or {}


            if Mod.KnifeUtil:IsSwingingKnife(knife) then
                for _, enemy in ipairs(Mod.KnifeUtil:GetEntitiesInSwing(player, knife)) do
                    if not knife:GetData().ASTRO_EntityCollisionMap[GetPtrHash(enemy)] then
                        knife:GetData().ASTRO_EntityCollisionMap[GetPtrHash(enemy)] = true
                        if enemy:ToNPC() then
                            if not self:IsOnCooldown(enemy:ToNPC(), self.Cooldown.KnifeSwing) then
                                self:PostNpcHit(knife, enemy:ToNPC(), true)
                            end
                        else
                            self:PreEntityCollision(knife, enemy, false)
                        end
                    end
                end
            else
                knife:GetData().ASTRO_EntityCollisionMap = {}
            end
        end
    end)

    ---@param knife EntityKnife
    Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, function (_, knife, offset)
        if knife:GetData()["ASTRO_" .. self.Name] and not knife:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            self:PostRender(knife, offset)
        end
    end)

    ---@param collider Entity
    Mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, function (_, knife, collider, low)
        if knife:GetData()["ASTRO_" .. self.Name] and not knife:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            if collider:ToNPC() then
                local entity = collider:ToNPC()
                -- normal knife and sumptorium knife
                if knife.Variant == 5 or knife.Variant == 0 then
                    if not self:IsOnCooldown(entity, self.Cooldown.KnifeHit) then
                        self:PostNpcHit(knife, entity)
                    end
                end
            end

            return self:PreEntityCollision(knife, collider, low)
        end
    end)
    --#endregion

    --#region LASER CODE (the scary one)
    ---@param laser EntityLaser
    Mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, function (_, laser)
        if not laser.SpawnerEntity or laser:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            return
        end

        if laser.Variant == LaserVariant.SHOOP and laser.MaxDistance == 0 then -- shoop da whoop
            return
        end

        local player = laser.SpawnerEntity:ToFamiliar() and laser.SpawnerEntity:ToFamiliar().Player or laser.SpawnerEntity:ToPlayer()
        if player and self:CheckKnifeLaserAffected(player, laser) then
            local sprite = laser:GetSprite()
            if self.Color then
                sprite.Color:SetColorize(self.Color.R + 0.3, self.Color.G + 0.2, self.Color.B + 0.2, 1)
            end

            laser:GetData()["ASTRO_" .. self.Name] = true
            self:PostFire(laser)
        end
    end)

    ---@param laser EntityLaser
    Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function (_, laser)
        if not laser.SpawnerEntity or laser:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            return
        end

        if laser.Variant == LaserVariant.SHOOP and laser.MaxDistance == 0 then -- shoop da whoop
            return
        end

        local player = laser.SpawnerEntity:ToFamiliar() and laser.SpawnerEntity:ToFamiliar().Player or laser.SpawnerEntity:ToPlayer()
        if player and self:CheckKnifeLaserAffected(player, laser) then
            local sprite = laser:GetSprite()
            if self.Color then
                sprite.Color:SetColorize(self.Color.R + 0.3, self.Color.G + 0.2, self.Color.B + 0.2, 1)
            end

            laser:GetData()["ASTRO_" .. self.Name] = true
        elseif laser:GetData()["ASTRO_" .. self.Name] then
            laser:GetData()["ASTRO_" .. self.Name] = false
            laser:GetSprite().Color = laser.SpawnerEntity:ToPlayer().LaserColor or Color.Default ---@diagnostic disable-line: undefined-field
        end

        if laser:GetData()["ASTRO_" .. self.Name] then
            self:PostUpdate(laser)

            local room = game:GetRoom()
            local samples = laser:GetNonOptimizedSamples()
            local collidedWidthGrid = {}
            local collidedWithEntity = {}
            for i = 0, #samples - 1 do
                local point = samples:Get(i) ---@diagnostic disable-line: undefined-field
                local gridEnt = room:GetGridEntityFromPos(point)
                if gridEnt and not collidedWidthGrid[gridEnt:GetGridIndex()] then
                    self:PostGridCollision(laser, point)
                    collidedWidthGrid[gridEnt:GetGridIndex()] = true
                end

                for _, entity in ipairs(Isaac.FindInRadius(point, laser.Size, EntityPartition.ENEMY)) do
                    local npc = entity:ToNPC()
                    if npc then
                        if not collidedWithEntity[GetPtrHash(npc)] then
                            if not self:PreEntityCollision(laser, npc, false) then
                                collidedWithEntity[GetPtrHash(npc)] = true
                            end

                            if self:IsOnCooldown(npc, self.Cooldown.Laser) then
                                break
                            end

                            self:PostNpcHit(laser, npc)
                        end
                    end
                end
            end
        end
    end)

    ---@param laser EntityLaser
    Mod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, function (_, laser, offset)
        if laser:GetData()["ASTRO_" .. self.Name] and not laser:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
            self:PostRender(laser, offset)
        end
    end)
    --#endregion

    -- TODO: 알트 캐릭터 지원
    -- --#region Samson code !!
    -- Mod:AddExtraCallback(Epiphany.ExtraCallbacks.SAMSON_PUNCH_ENTITY, function (player, npc, isSlam, point)
    --     if player and self:CheckKnifeLaserAffected(player, nil) then
    --         self:PostNpcHit(player, npc, false, true)
    --     end
    -- end)
    -- --#endregion

    -- --#region Cain Bag code
    -- Mod:AddExtraCallback(Epiphany.ExtraCallbacks.CAIN_POST_SWING_HIT, function (_, bag, entity, player, SbData, dmgDealt)

    --     if player and entity:ToNPC() and self:CheckTearAffected(player) then
    --         self:PostNpcHit(bag, entity:ToNPC(), nil, nil, true)
    --     end
    -- end)

    -- Mod:AddExtraCallback(Epiphany.ExtraCallbacks.CAIN_POST_BAG_THROW, function (_, bag, TbData)
    --     if not TbData.PlayerOwner or TbData["ASTRO_" .. self.Name .. "_Disabled"] then
    --         return
    --     end

    --     local player = TbData.PlayerOwner
    --     if player and self:CheckTearAffected(player) then
    --         local sprite = bag:GetSprite()

    --         if self.Color then
    --             sprite.Color = self.Color
    --         end

    --         TbData["ASTRO_" .. self.Name] = true
    --         self:PostFire(bag)
    --     end
    -- end)

    -- Mod:AddExtraCallback(Epiphany.ExtraCallbacks.CAIN_POST_BAG_HIT, function (_, bag, entity, TbData, dmgDealt)
    --     if TbData["ASTRO_" .. self.Name] and not TbData["ASTRO_" .. self.Name .. "_Disabled"] then
    --         if entity:ToNPC() then
    --             self:PostNpcHit(bag, entity:ToNPC(), nil, nil, true)
    --         end
    --     end
    -- end)
    -- --#endregion

    --#region Bomb code (the easy one)
    if self.ShouldAffectBombs then

        ---@param effect EntityEffect
        Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)

            if not effect.SpawnerEntity then
                return
            end

            local player = effect.SpawnerEntity:ToFamiliar() and effect.SpawnerEntity:ToFamiliar().Player or effect.SpawnerEntity:ToPlayer()
            if player and self:CheckTearAffected(player) then
                local sprite = effect:GetSprite()
                if self.Color then
                    sprite.Color = self.Color
                end

                effect:GetData()["ASTRO_" .. self.Name] = true
                self:PostFire(effect)
            end
        end, EffectVariant.ROCKET)

        ---@param bomb EntityBomb
        Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function (_, bomb)
            if not bomb.IsFetus then
                return
            end

            local player = bomb.SpawnerEntity:ToFamiliar() and bomb.SpawnerEntity:ToFamiliar().Player or bomb.SpawnerEntity:ToPlayer()
            if bomb.FrameCount == 1 and player and self:CheckTearAffected(player) then
                local sprite = bomb:GetSprite()
                if self.Color then
                    sprite.Color = self.Color
                end

                bomb:GetData()["ASTRO_" .. self.Name] = true
                self:PostFire(bomb)
            end

            if not bomb.SpawnerEntity or bomb:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
                return
            end

            if bomb:GetData()["ASTRO_" .. self.Name] and not bomb:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
                self:PostUpdate(bomb)

                if bomb:CollidesWithGrid() then
                    self:PostGridCollision(bomb, bomb.Position)
                end

                if bomb:GetSprite():IsPlaying("Explode") and not bomb:GetData()["ASTRO_" .. self.Name .. "_BombExploded"] then
                    self:PostExplode(bomb)
                    bomb:GetData()["ASTRO_" .. self.Name .. "_BombExploded"] = true
                end
            end
        end)

        ---@param entity Entity
        ---@param source EntityRef
        Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function (_, entity, _, _, source)
            local bomb = source.Entity and source.Entity:ToBomb()
            local effect = source.Entity and source.Entity:ToEffect()
            if bomb and bomb:GetData()["ASTRO_" .. self.Name] and not bomb:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
                if bomb.IsFetus and entity:ToNPC() then
                    self:PostNpcHit(bomb, entity:ToNPC())
                end
            end

            if effect and effect:GetData()["ASTRO_" .. self.Name] and not effect:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
                if entity:ToNPC() then
                    self:PostNpcHit(effect, entity:ToNPC())
                end
            end
        end)

        ---@param collider Entity
        Mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, function (_, bomb, collider, low)
            if bomb:GetData()["ASTRO_" .. self.Name] and not bomb:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then

                if not bomb.IsFetus then
                    return
                end

                if collider:ToNPC() then
                    self:PostNpcHit(bomb, collider:ToNPC())
                end

                return self:PreEntityCollision(bomb, collider, low)
            end
        end)

        ---@param bomb EntityBomb
        Mod:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, function (_, bomb, offset)
            if bomb:GetData()["ASTRO_" .. self.Name] and not bomb:GetData()["ASTRO_" .. self.Name .. "_Disabled"] then
                self:PostRender(bomb, offset)
            end
        end)
    end
    --#endregion

    return self
end

return TearModifier

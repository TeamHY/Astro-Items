Astro.Collectible.COPERNICUS = Isaac.GetItemIdByName("Copernicus")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
			Astro:AddEIDCollectible(
				Astro.Collectible.COPERNICUS,
				"코페르니쿠스",
				"지동설",
				"↑ {{TearsSmall}}연사 +0.77" ..
				"#적 명중 시 적 주변을 도는 유령 탄환이 소환되며;" ..
				"#{{ArrowGrayRight}} 각 적당 일정 횟수 이상 명중시 유령 탄환이 적을 공격합니다."
			)
		end
    end
)


--#region Variables
-- =============================================================================

-- Linen Shroud Variables -------------------------------------------------------

-- =============================================================================
local Mod = Astro

local LINEN_SHROUD = {}

LINEN_SHROUD.ID = Astro.Collectible.COPERNICUS

LINEN_SHROUD.ENCY_POOLS = {
	"AngelPool",
	"GreedAngelPool",
}

LINEN_SHROUD.START_DAMAGE_MULT = 1
LINEN_SHROUD.MIN_DAMAGE_MULT = 0.7
LINEN_SHROUD.DAMAGE_MULT_DRAIN_AMOUNT = 0.05
LINEN_SHROUD.DAMAGE_MULT_DRAIN_INTERVAL = 6
LINEN_SHROUD.DAMAGE_MULT_ADD_BONUS = 0.12

-- cooldown before tears can orbit again, after an orbit went in
LINEN_SHROUD.ORBIT_COOLDOWN = 7

LINEN_SHROUD.LASER_HIT_COOLDOWN = 3
LINEN_SHROUD.KNIFE_HIT_COOLDOWN = 2
LINEN_SHROUD.KNIFE_SWING_COOLDOWN = 4
LINEN_SHROUD.LUDO_HIT_COOLDOWN = 7
LINEN_SHROUD.C_SECTION_COOLDOWN = 6

LINEN_SHROUD.MONSTROS_LUNG_ALLOWED_TEARS = 3

LINEN_SHROUD.OFFSET = 12
LINEN_SHROUD.ORBIT_SPEED = 5
LINEN_SHROUD.MAX_ORBIT_TIME = 8 -- how long it takes until it reaches max orbit distance

LINEN_SHROUD.LASER_RADIUS = 1
LINEN_SHROUD.LASER_TIMEOUT = 10
LINEN_SHROUD.LASER_DAMAGE_REDUCTION_MULT = 0.4

LINEN_SHROUD.FETUS_BOMB_DAMAGE_MULTIPLIER = 7 -- to be accurate to the damage output youre doing with the bombs
LINEN_SHROUD.EPIC_FETUS_BOMB_DAMAGE_MULTIPLIER = 20

LINEN_SHROUD.TEARS_UP = 0.77

LINEN_SHROUD.TEAR_SPRITES = {
	SPIRIT_SWORD = "gfx/tears/copernicus/spirit_sword.png",
	MOMS_KNIFE = "gfx/tears/copernicus/moms_knife.png"
}

LINEN_SHROUD.MAX_TEAR_MINIMUM = 3
LINEN_SHROUD.MAX_TEAR_MAXIMUM = 10

-- tears that have a defined front and back, will be rotated to face the target
LINEN_SHROUD.DIRECTIONAL_TEARS = {
	[TearVariant.CUPID_BLUE] = true,
	[TearVariant.CUPID_BLOOD] = true,
    [TearVariant.NAIL] = true,
    [TearVariant.COIN] = true,
    [TearVariant.NEEDLE] = true,
    [TearVariant.PUPULA] = true,
    [TearVariant.PUPULA_BLOOD] = true,
    [TearVariant.NAIL_BLOOD] = true,
    [TearVariant.FIST] = true,
    [TearVariant.ICE] = true,
    [TearVariant.KEY] = true,
    [TearVariant.KEY_BLOOD] = true,
    [TearVariant.ERASER] = true,
    [TearVariant.SWORD_BEAM] = true,
    [TearVariant.TECH_SWORD_BEAM] = true
}

LINEN_SHROUD.BANNED_TEARFLAGS = TearFlags.TEAR_HOMING
							  | TearFlags.TEAR_ABSORB
							  | TearFlags.TEAR_SHRINK
							  | TearFlags.TEAR_GLOW
							  | TearFlags.TEAR_LASER
							  | TearFlags.TEAR_OCCULT
							  | TearFlags.TEAR_BOOMERANG
							  | TearFlags.TEAR_ORBIT
							  | TearFlags.TEAR_LASERSHOT
							  | TearFlags.TEAR_LUDOVICO
--#endregion
--#region Functions
-- =============================================================================

-- Linen Shroud Functions ---------------------------------------------------

-- =============================================================================


---Gets the max amount of tears in a ring a player can have
---@param player EntityPlayer
function LINEN_SHROUD:GetMaxTears(player)
	local tps = Mod:Delay2Tears(player.MaxFireDelay)
	return Mod:Clamp(
		LINEN_SHROUD.MAX_TEAR_MINIMUM + math.floor(0.75 * tps),
		LINEN_SHROUD.MAX_TEAR_MINIMUM,
		LINEN_SHROUD.MAX_TEAR_MAXIMUM
	)
end

---@param npc EntityNPC
function LINEN_SHROUD:WipeTearsForNPC(npc)
	local data = npc:GetData().ASTRO_LinenShroudData
	if data and data.GhostTears then
		for _, tear in ipairs(data.GhostTears) do
			tear:Die()
		end

		data.GhostTears = {}
	end
end


--#endregion
--#region Modifier
-- =============================================================================

-- Linen Shroud Normal Modifier ------------------------------------------------

-- =============================================================================

LINEN_SHROUD.TEAR_MODIFIER = Mod.TearModifier.New({
	Name = "LinenShroud",
	Items = { LINEN_SHROUD.ID },
	MinLuck = 0,
	MaxLuck = 15,
	MinChance = 1,
	MaxChance = 1,
	ShouldAffectBombs = true
})

local modifier = LINEN_SHROUD.TEAR_MODIFIER

function LINEN_SHROUD:ActivateTear(tear, npc, player)
	local tearData = tear:GetData().ASTRO_LinenShroudData
	tear:GetData()["ASTRO_LinenShroudOrbital"] = nil
	tearData.Active = true
	tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	tear.Velocity = (npc.Position - tear.Position):Normalized() * 10 -- 10 is an arbitrary number to go fast

	tear.CollisionDamage = (tearData.OriginalDamage or tear.CollisionDamage) * tearData.Multiplier
	tear.FallingAcceleration = tearData.FallingAcceleration
	tear.FallingSpeed = tearData.FallingSpeed

	npc:GetData().ASTRO_LinenShroudCooldown = LINEN_SHROUD.ORBIT_COOLDOWN
	tear.Parent = player

end

---@param hitter EntityTear | EntityKnife | EntityLaser
---@param npc EntityNPC
function modifier:PostNpcHit(hitter, npc, isKnifeSwing, isSamsonPunch)

	---@type EntityPlayer?
	local player = modifier:GetPlayerFromHitter(hitter)
	if not player then return end
	local playerData = player:GetData().ASTRO_LinenShroudDebounces
	if not playerData then
		player:GetData().ASTRO_LinenShroudDebounces = {}
		playerData = player:GetData().ASTRO_LinenShroudDebounces
	end

	if not npc:IsVulnerableEnemy() or not npc:IsActiveEnemy() then
		return
	end

	local hitterData = isSamsonPunch and {} or hitter:GetData()
	if hitterData[tostring(GetPtrHash(npc))] then
		return
	end

	if npc:GetData().ASTRO_LinenShroudCooldown and npc:GetData().ASTRO_LinenShroudCooldown > 0 then
		return
	end

	local frame = Game():GetFrameCount()

	if player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then
		playerData.MonstroTearCount = playerData.MonstroTearCount or 0
	end

	if playerData.MonstroTearCount and playerData.MonstroTearCount >= LINEN_SHROUD.MONSTROS_LUNG_ALLOWED_TEARS then
		playerData.MonstroDebounce = frame + 1
	end

	if playerData.MonstroDebounce and playerData.MonstroDebounce > frame then
		return
	end

	local data = npc:GetData().ASTRO_LinenShroudData
	if not npc:GetData().ASTRO_LinenShroudData then
		npc:GetData().ASTRO_LinenShroudData = {
			GhostTears = {}
		}
		data = npc:GetData().ASTRO_LinenShroudData
	end

	if hitter.Type == EntityType.ENTITY_LASER and hitter.Variant == LaserVariant.ELECTRIC then -- tech zero to avoid infinite loops
		return
	end

	if #data.GhostTears < LINEN_SHROUD:GetMaxTears(player) and not hitterData.ASTRO_LinenShroudOrbital then
		local position = hitter.Type == EntityType.ENTITY_TEAR and hitter.Position or npc.Position
		local ghostTear = player:FireTear(position, Vector.Zero, false, true, false, player, 1)
		ghostTear.Color.A = 0.5
		ghostTear:GetData()["ASTRO_LinenShroud_Disabled"] = true

		local hadGodhead = ghostTear:HasTearFlags(TearFlags.TEAR_GLOW)
		ghostTear:ClearTearFlags(LINEN_SHROUD.BANNED_TEARFLAGS)
		ghostTear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_NO_GRID_DAMAGE)

		if player:HasWeaponType(WeaponType.WEAPON_ROCKETS) then -- epic fetus
			ghostTear.CollisionDamage = ghostTear.CollisionDamage * LINEN_SHROUD.EPIC_FETUS_BOMB_DAMAGE_MULTIPLIER
		elseif player:HasWeaponType(WeaponType.WEAPON_BOMBS) then
			ghostTear.CollisionDamage = ghostTear.CollisionDamage * LINEN_SHROUD.FETUS_BOMB_DAMAGE_MULTIPLIER
		end

		if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
			ghostTear:ClearTearFlags(TearFlags.TEAR_BURSTSPLIT) -- haemolacria fix
		end

		ghostTear.KnockbackMultiplier = 0

		for _, tear in ipairs(data.GhostTears) do
			if tear:GetData().ASTRO_LinenShroudData then
				tear:GetData().ASTRO_LinenShroudData.Multiplier = tear:GetData().ASTRO_LinenShroudData.Multiplier + LINEN_SHROUD.DAMAGE_MULT_ADD_BONUS
			end
		end

		ghostTear:GetData()["ASTRO_LinenShroudOrbital"] = true
		ghostTear:GetData().ASTRO_LinenShroudData = {
			Multiplier = LINEN_SHROUD.START_DAMAGE_MULT,
			Active = false, -- if it should hit the target
			FallingAcceleration = ghostTear.FallingAcceleration,
			FallingSpeed = ghostTear.FallingSpeed,
			Parent = npc,
			Godhead = hadGodhead
		}

		if hitter.Type == EntityType.ENTITY_KNIFE and ghostTear.Variant == TearVariant.BLUE then
			local sprite = ghostTear:GetSprite()
			if hitter.Variant == 10 then -- spirit sword
				sprite:ReplaceSpritesheet(0, LINEN_SHROUD.TEAR_SPRITES.SPIRIT_SWORD)
				sprite:LoadGraphics()
			else --mom's knife
				sprite:ReplaceSpritesheet(0, LINEN_SHROUD.TEAR_SPRITES.MOMS_KNIFE)
				sprite:LoadGraphics()
			end


			ghostTear:GetData().ASTRO_LinenShroudData.PointTowardsTarget = true
		end

		if LINEN_SHROUD.DIRECTIONAL_TEARS[ghostTear.Variant] then
			ghostTear:GetData().ASTRO_LinenShroudData.PointTowardsTarget = true
		end

		if hitter.Type == EntityType.ENTITY_LASER then
			ghostTear:GetData().ASTRO_LinenShroudData.OriginalDamage = hitter.CollisionDamage
		end

		ghostTear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		ghostTear.Scale = 1
		ghostTear.FallingAcceleration = -0.1
		ghostTear.FallingSpeed = 0

		table.insert(data.GhostTears, ghostTear)
	elseif not hitter:GetData().ASTRO_LinenShroudOrbital then
		-- activate the tears
		for _, tear in ipairs(data.GhostTears) do
			local tearData = tear:GetData().ASTRO_LinenShroudData

			if tearData then
				LINEN_SHROUD:ActivateTear(tear, npc, player)
			end
		end

		data.GhostTears = {}
	end

	if hitter.Type ~= EntityType.ENTITY_PLAYER and hitter.Type == EntityType.ENTITY_TEAR
	 and not hitter:ToTear():HasTearFlags(TearFlags.TEAR_LUDOVICO) and not hitter:ToTear():HasTearFlags(TearFlags.TEAR_FETUS) then
		hitterData[tostring(GetPtrHash(npc))] = true
	end

	if player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then

		if playerData.MonstroDebounce ~= frame then
			playerData.MonstroTearCount = 0
		end

		playerData.MonstroTearCount = playerData.MonstroTearCount and playerData.MonstroTearCount + 1 or 1
	end
end

---workaround for knives being the worst ever
---@param entity Entity
---@param source EntityRef
function LINEN_SHROUD:PostNpcKnifeHit(entity, _, _, source)
	local npc = entity:ToNPC()
	if npc and npc:IsVulnerableEnemy() and npc:IsActiveEnemy() then
		local player = source.Entity and source.Entity:ToPlayer()
		if player and player:HasCollectible(LINEN_SHROUD.ID) then
			if player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD) then
				local animation = player:GetActiveWeaponEntity():GetSprite():GetAnimation()
				if animation:match("Idle") then
					modifier:PostNpcHit(player:GetActiveWeaponEntity():ToKnife(), npc, true)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LINEN_SHROUD.PostNpcKnifeHit)

--#endregion
--#region Orbital modifier
-- =============================================================================

-- Linen Shroud Orbital Modifier (around npcs) ---------------------------------

-- =============================================================================

LINEN_SHROUD.ORBITAL_TEAR_MODIFIER = Mod.TearModifier.New({
	Name = "LinenShroudOrbital",
	Items = {LINEN_SHROUD.ID},
	MinLuck = 0,
	MaxLuck = 15,
	MinChance = 0, -- only apply manually
	MaxChance = 0
})

local orbitalModifier = LINEN_SHROUD.ORBITAL_TEAR_MODIFIER

---@param npc EntityNPC
function LINEN_SHROUD:UpdateTearOrbit(npc)
	local npcData = npc:GetData().ASTRO_LinenShroudData

	if npc:GetData().ASTRO_LinenShroudCooldown then
		npc:GetData().ASTRO_LinenShroudCooldown = math.max(npc:GetData().ASTRO_LinenShroudCooldown - 1, 0)
	end

	if not npcData then
		return
	end

	local offset = npc.Size + npc.SpriteScale:Length() + LINEN_SHROUD.OFFSET
	local angleStep = 360 / #npcData.GhostTears
	for i = 1, #npcData.GhostTears do
		local tear = npcData.GhostTears[i]

		if not tear then
			goto skip
		end

		if not tear:Exists() then
			table.remove(npcData.GhostTears, i)
			goto skip
		end

		local data = tear:GetData().ASTRO_LinenShroudData
		if data and not data.Active then
			offset = math.min((tear.FrameCount / LINEN_SHROUD.MAX_ORBIT_TIME), 1) * offset
			local angle = angleStep * i + npc.FrameCount * LINEN_SHROUD.ORBIT_SPEED
			tear.Position = Mod:Lerp(tear.Position, npc.Position + npc.Velocity + Vector.FromAngle(angle) * offset, 0.35)
			tear.Color.A = 0.5
		end

		::skip::
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, LINEN_SHROUD.UpdateTearOrbit)

---@param tear EntityTear
function LINEN_SHROUD:UpdateTearRotation(tear)
	local data = tear:GetData().ASTRO_LinenShroudData

	if not data then
		return
	end

	if not data.Active and data.PointTowardsTarget  then
		tear.Rotation = (data.Parent.Position - tear.Position):GetAngleDegrees()
		tear:GetSprite().Rotation = tear.Rotation
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, LINEN_SHROUD.UpdateTearRotation)

--- sometimes setting the collision class doesnt work.
--- still necessary to do, for bombs
function LINEN_SHROUD:EnsureCancelledCollision(tear)

	local data = tear:GetData().ASTRO_LinenShroudData

	if not data then
		return
	end

	if not data.Active then
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, LINEN_SHROUD.EnsureCancelledCollision)

---@param tear EntityTear
function orbitalModifier:PostUpdate(tear)
	local data = tear:GetData().ASTRO_LinenShroudData

	if not data or not data.Parent or not data.Parent:Exists() or data.Parent:IsDead() then
		tear:Die()
	end

	local sprite = tear:GetSprite()
	local color = sprite.Color
	local newColor = Color(color.R, color.G, color.B, 0.5, color.RO, color.GO, color.BO)
	tear:GetSprite().Color = newColor

	local damageMax = 0
	if data and not data.Active then
		if tear.FrameCount % LINEN_SHROUD.DAMAGE_MULT_DRAIN_INTERVAL == 0 then
			data.Multiplier = math.max(data.Multiplier - LINEN_SHROUD.DAMAGE_MULT_DRAIN_AMOUNT, LINEN_SHROUD.MIN_DAMAGE_MULT)
			tear.Scale = (data.Multiplier / LINEN_SHROUD.START_DAMAGE_MULT)

			damageMax = damageMax + ((tear:GetData().ASTRO_LinenShroudData.OriginalDamage or tear.CollisionDamage) * data.Multiplier)
		end
	end

	if damageMax > data.Parent.HitPoints then
		local tearData = tear:GetData().ASTRO_LinenShroudData

		if tearData then
			LINEN_SHROUD:ActivateTear(tear, tearData.Parent, tear.SpawnerEntity:ToPlayer())
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, LINEN_SHROUD.WipeTearsForNPC)

--#endregion
--#region Callbacks
-- =============================================================================

-- Other Callbacks -------------------------------------------------------------

-- =============================================================================

---@param player EntityPlayer
function LINEN_SHROUD:HandleCache(player)
	local count = player:GetCollectibleNum(LINEN_SHROUD.ID)
	local tps = Mod:Delay2Tears(player.MaxFireDelay)
	tps = tps + LINEN_SHROUD.TEARS_UP * count
	player.MaxFireDelay = Mod:Tears2Delay(tps)
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LINEN_SHROUD.HandleCache, CacheFlag.CACHE_FIREDELAY)
--#endregion

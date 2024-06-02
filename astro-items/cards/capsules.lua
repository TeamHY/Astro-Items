--- Credit to Xalum(Retribution)

local CAPSULE_SPAWN_CHANCE             = 1 / 32

AstroItems.Card.DAMAGE_CAPSULE              = Isaac.GetCardIdByName("Sword Capsule")
AstroItems.Card.HEALTH_CAPSULE              = Isaac.GetCardIdByName("Heart Capsule")
AstroItems.Card.FIREDELAY_CAPSULE           = Isaac.GetCardIdByName("Tear Capsule")
AstroItems.Card.RANGE_CAPSULE               = Isaac.GetCardIdByName("Bow Capsule")
AstroItems.Card.SHOTSPEED_CAPSULE           = Isaac.GetCardIdByName("Fling Capsule")
AstroItems.Card.SPEED_CAPSULE               = Isaac.GetCardIdByName("Boot Capsule")
AstroItems.Card.LUCK_CAPSULE                = Isaac.GetCardIdByName("Clover Capsule")
AstroItems.Card.HEALTH_DAMAGE_CAPSULE       = Isaac.GetCardIdByName("Combo Capsule")
AstroItems.Card.LUCK_DAMAGE_CAPSULE         = Isaac.GetCardIdByName(" Combo Capsule")
AstroItems.Card.RANGE_DAMAGE_CAPSULE        = Isaac.GetCardIdByName("  Combo Capsule")
AstroItems.Card.SHOTSPEED_DAMAGE_CAPSULE    = Isaac.GetCardIdByName("   Combo Capsule")
AstroItems.Card.SPEED_DAMAGE_CAPSULE        = Isaac.GetCardIdByName("    Combo Capsule")
AstroItems.Card.FIREDELAY_DAMAGE_CAPSULE    = Isaac.GetCardIdByName("     Combo Capsule")
AstroItems.Card.HEALTH_LUCK_CAPSULE         = Isaac.GetCardIdByName("      Combo Capsule")
AstroItems.Card.HEALTH_RANGE_CAPSULE        = Isaac.GetCardIdByName("       Combo Capsule")
AstroItems.Card.HEALTH_SHOTSPEED_CAPSULE    = Isaac.GetCardIdByName("        Combo Capsule")
AstroItems.Card.HEALTH_SPEED_CAPSULE        = Isaac.GetCardIdByName("         Combo Capsule")
AstroItems.Card.HEALTH_FIREDELAY_CAPSULE    = Isaac.GetCardIdByName("          Combo Capsule")
AstroItems.Card.LUCK_RANGE_CAPSULE          = Isaac.GetCardIdByName("           Combo Capsule")
AstroItems.Card.LUCK_SHOTSPEED_CAPSULE      = Isaac.GetCardIdByName("            Combo Capsule")
AstroItems.Card.LUCK_SPEED_CAPSULE          = Isaac.GetCardIdByName("             Combo Capsule")
AstroItems.Card.LUCK_FIREDELAY_CAPSULE      = Isaac.GetCardIdByName("              Combo Capsule")
AstroItems.Card.RANGE_SHOTSPEED_CAPSULE     = Isaac.GetCardIdByName("               Combo Capsule")
AstroItems.Card.RANGE_SPEED_CAPSULE         = Isaac.GetCardIdByName("                Combo Capsule")
AstroItems.Card.RANGE_FIREDELAY_CAPSULE     = Isaac.GetCardIdByName("                 Combo Capsule")
AstroItems.Card.SHOTSPEED_SPEED_CAPSULE     = Isaac.GetCardIdByName("                  Combo Capsule")
AstroItems.Card.SHOTSPEED_FIREDELAY_CAPSULE = Isaac.GetCardIdByName("                   Combo Capsule")
AstroItems.Card.SPEED_FIREDELAY_CAPSULE     = Isaac.GetCardIdByName("                    Combo Capsule")

if EID then
	EID:addCard(AstroItems.Card.DAMAGE_CAPSULE, "↑ {{DamageSmall}}공격력 +0.5")
	EID:addCard(AstroItems.Card.HEALTH_CAPSULE, "↑ {{Heart}}최대 체력 +1")
	EID:addCard(AstroItems.Card.FIREDELAY_CAPSULE, "↑ {{TearsSmall}}연사(고정) +0.25")
	EID:addCard(AstroItems.Card.RANGE_CAPSULE, "↑ {{RangeSmall}}사거리 +2")
	EID:addCard(AstroItems.Card.SHOTSPEED_CAPSULE, "↑ {{ShotspeedSmall}}탄속 +0.1")
	EID:addCard(AstroItems.Card.SPEED_CAPSULE, "↑ {{SpeedSmall}}이동속도 +0.1")
	EID:addCard(AstroItems.Card.LUCK_CAPSULE, "↑ {{LuckSmall}}행운 +1")
	EID:addCard(AstroItems.Card.HEALTH_DAMAGE_CAPSULE, "↑ {{Heart}}최대 체력 +1#↑ {{Damage}}공격력 +0.5")
	EID:addCard(AstroItems.Card.LUCK_DAMAGE_CAPSULE, "↑ {{LuckSmall}}행운 +1#↑ {{Damage}}공격력 +0.5")
	EID:addCard(AstroItems.Card.RANGE_DAMAGE_CAPSULE, "↑ {{RangeSmall}}사거리 +2#↑ {{Damage}}공격력 +0.5")
	EID:addCard(AstroItems.Card.SHOTSPEED_DAMAGE_CAPSULE, "↑ {{ShotspeedSmall}}탄속 +0.1#↑ {{Damage}}공격력 +0.5")
	EID:addCard(AstroItems.Card.SPEED_DAMAGE_CAPSULE, "↑ {{SpeedSmall}}이동속도 +0.1#↑ {{Damage}}공격력 +0.5")
	EID:addCard(AstroItems.Card.FIREDELAY_DAMAGE_CAPSULE, "↑ {{TearsSmall}}연사(고정) +0.25#↑ {{Damage}}공격력 +0.5")
	EID:addCard(AstroItems.Card.HEALTH_LUCK_CAPSULE, "↑ {{Heart}}최대 체력 +1#↑ {{LuckSmall}}행운 +1")
	EID:addCard(AstroItems.Card.HEALTH_RANGE_CAPSULE, "↑ {{Heart}}최대 체력 +1#↑ {{RangeSmall}}사거리 +2")
	EID:addCard(AstroItems.Card.HEALTH_SHOTSPEED_CAPSULE, "↑ {{Heart}}최대 체력 +1#↑ {{ShotspeedSmall}}탄속 +0.1")
	EID:addCard(AstroItems.Card.HEALTH_SPEED_CAPSULE, "↑ {{Heart}}최대 체력 +1#↑ {{SpeedSmall}}이동속도 +0.1")
	EID:addCard(AstroItems.Card.HEALTH_FIREDELAY_CAPSULE, "↑ {{Heart}}최대 체력 +1#↑ {{TearsSmall}}연사 +0.25")
	EID:addCard(AstroItems.Card.LUCK_RANGE_CAPSULE, "↑ {{LuckSmall}}행운 +1#↑ {{RangeSmall}}사거리 +2")
	EID:addCard(AstroItems.Card.LUCK_SHOTSPEED_CAPSULE, "↑ {{LuckSmall}}행운 +1#↑ {{ShotspeedSmall}}탄속 +0.1")
	EID:addCard(AstroItems.Card.LUCK_SPEED_CAPSULE, "↑ {{LuckSmall}}행운 +1#↑ {{SpeedSmall}}이동속도 +0.1")
	EID:addCard(AstroItems.Card.LUCK_FIREDELAY_CAPSULE, "↑ {{LuckSmall}}행운 +1#↑ {{TearsSmall}}연사 +0.25")
	EID:addCard(AstroItems.Card.RANGE_SHOTSPEED_CAPSULE, "↑ {{RangeSmall}}사거리 +2#↑ {{ShotspeedSmall}}탄속 +0.1")
	EID:addCard(AstroItems.Card.RANGE_SPEED_CAPSULE, "↑ {{RangeSmall}}사거리 +2#↑ {{SpeedSmall}}이동속도 +0.1")
	EID:addCard(AstroItems.Card.RANGE_FIREDELAY_CAPSULE, "↑ {{RangeSmall}}사거리 +2#↑ {{TearsSmall}}연사 +0.25")
	EID:addCard(AstroItems.Card.SHOTSPEED_SPEED_CAPSULE, "↑ {{ShotspeedSmall}}탄속 +0.1#↑ {{SpeedSmall}}이동속도 +0.1")
	EID:addCard(AstroItems.Card.SHOTSPEED_FIREDELAY_CAPSULE, "↑ {{ShotspeedSmall}}탄속 +0.1#↑ {{TearsSmall}}연사 +0.25")
	EID:addCard(AstroItems.Card.SPEED_FIREDELAY_CAPSULE, "↑ {{SpeedSmall}}이동속도 +0.1#↑ {{TearsSmall}}연사 +0.25")
end

local capsuleWeights      = {
	-- Super low weight
	[AstroItems.Card.HEALTH_CAPSULE]    = 0.5,

	-- Low weight
	[AstroItems.Card.DAMAGE_CAPSULE]    = 1,
	[AstroItems.Card.FIREDELAY_CAPSULE] = 1,
	[AstroItems.Card.SHOTSPEED_CAPSULE] = 1, -- Not necessarily because of strength, lots of shotspeed is just kinda lame

	-- High weight
	[AstroItems.Card.RANGE_CAPSULE]     = 1.2,
	[AstroItems.Card.SPEED_CAPSULE]     = 1.2,
	[AstroItems.Card.LUCK_CAPSULE]      = 1.2,
}

local goodCapsuleWeights  = {
	[AstroItems.Card.HEALTH_CAPSULE]    = 0.75,
	[AstroItems.Card.DAMAGE_CAPSULE]    = 1.5,
	[AstroItems.Card.FIREDELAY_CAPSULE] = 1.5,
	[AstroItems.Card.LUCK_CAPSULE]      = 1,
}

local capsuleToTrackers   = {
	[AstroItems.Card.DAMAGE_CAPSULE]              = { "damageCapsules" },
	[AstroItems.Card.FIREDELAY_CAPSULE]           = { "tearsCapsules" },
	[AstroItems.Card.RANGE_CAPSULE]               = { "rangeCapsules" },
	[AstroItems.Card.SHOTSPEED_CAPSULE]           = { "shotspeedCapsules" },
	[AstroItems.Card.SPEED_CAPSULE]               = { "speedCapsules" },
	[AstroItems.Card.LUCK_CAPSULE]                = { "luckCapsules" },

	[AstroItems.Card.HEALTH_DAMAGE_CAPSULE]       = { "damageCapsules" },
	[AstroItems.Card.LUCK_DAMAGE_CAPSULE]         = { "damageCapsules", "luckCapsules" },
	[AstroItems.Card.RANGE_DAMAGE_CAPSULE]        = { "damageCapsules", "rangeCapsules" },
	[AstroItems.Card.SHOTSPEED_DAMAGE_CAPSULE]    = { "damageCapsules", "shotspeedCapsules" },
	[AstroItems.Card.SPEED_DAMAGE_CAPSULE]        = { "damageCapsules", "speedCapsules" },
	[AstroItems.Card.FIREDELAY_DAMAGE_CAPSULE]    = { "damageCapsules", "tearsCapsules" },
	[AstroItems.Card.HEALTH_LUCK_CAPSULE]         = { "luckCapsules" },
	[AstroItems.Card.HEALTH_RANGE_CAPSULE]        = { "rangeCapsules" },
	[AstroItems.Card.HEALTH_SHOTSPEED_CAPSULE]    = { "shotspeedCapsules" },
	[AstroItems.Card.HEALTH_SPEED_CAPSULE]        = { "speedCapsules" },
	[AstroItems.Card.HEALTH_FIREDELAY_CAPSULE]    = { "tearsCapsules" },
	[AstroItems.Card.LUCK_RANGE_CAPSULE]          = { "luckCapsules", "rangeCapsules" },
	[AstroItems.Card.LUCK_SHOTSPEED_CAPSULE]      = { "luckCapsules", "shotspeedCapsules" },
	[AstroItems.Card.LUCK_SPEED_CAPSULE]          = { "luckCapsules", "speedCapsules" },
	[AstroItems.Card.LUCK_FIREDELAY_CAPSULE]      = { "luckCapsules", "tearsCapsules" },
	[AstroItems.Card.RANGE_SHOTSPEED_CAPSULE]     = { "rangeCapsules", "shotspeedCapsules" },
	[AstroItems.Card.RANGE_SPEED_CAPSULE]         = { "rangeCapsules", "speedCapsules" },
	[AstroItems.Card.RANGE_FIREDELAY_CAPSULE]     = { "rangeCapsules", "tearsCapsules" },
	[AstroItems.Card.SHOTSPEED_SPEED_CAPSULE]     = { "shotspeedCapsules", "speedCapsules" },
	[AstroItems.Card.SHOTSPEED_FIREDELAY_CAPSULE] = { "shotspeedCapsules", "tearsCapsules" },
	[AstroItems.Card.SPEED_FIREDELAY_CAPSULE]     = { "speedCapsules", "tearsCapsules" },
}

local capsuleToCacheFlags = {
	[AstroItems.Card.DAMAGE_CAPSULE]              = { CacheFlag.CACHE_DAMAGE },
	[AstroItems.Card.FIREDELAY_CAPSULE]           = { CacheFlag.CACHE_FIREDELAY },
	[AstroItems.Card.RANGE_CAPSULE]               = { CacheFlag.CACHE_RANGE },
	[AstroItems.Card.SHOTSPEED_CAPSULE]           = { CacheFlag.CACHE_SHOTSPEED },
	[AstroItems.Card.SPEED_CAPSULE]               = { CacheFlag.CACHE_SPEED },
	[AstroItems.Card.LUCK_CAPSULE]                = { CacheFlag.CACHE_LUCK },

	[AstroItems.Card.HEALTH_DAMAGE_CAPSULE]       = { CacheFlag.CACHE_DAMAGE },
	[AstroItems.Card.LUCK_DAMAGE_CAPSULE]         = { CacheFlag.CACHE_DAMAGE, CacheFlag.CACHE_LUCK },
	[AstroItems.Card.RANGE_DAMAGE_CAPSULE]        = { CacheFlag.CACHE_DAMAGE, CacheFlag.CACHE_RANGE },
	[AstroItems.Card.SHOTSPEED_DAMAGE_CAPSULE]    = { CacheFlag.CACHE_DAMAGE, CacheFlag.CACHE_SHOTSPEED },
	[AstroItems.Card.SPEED_DAMAGE_CAPSULE]        = { CacheFlag.CACHE_DAMAGE, CacheFlag.CACHE_SPEED },
	[AstroItems.Card.FIREDELAY_DAMAGE_CAPSULE]    = { CacheFlag.CACHE_DAMAGE, CacheFlag.CACHE_FIREDELAY },
	[AstroItems.Card.HEALTH_LUCK_CAPSULE]         = { CacheFlag.CACHE_LUCK },
	[AstroItems.Card.HEALTH_RANGE_CAPSULE]        = { CacheFlag.CACHE_RANGE },
	[AstroItems.Card.HEALTH_SHOTSPEED_CAPSULE]    = { CacheFlag.CACHE_SHOTSPEED },
	[AstroItems.Card.HEALTH_SPEED_CAPSULE]        = { CacheFlag.CACHE_SPEED },
	[AstroItems.Card.HEALTH_FIREDELAY_CAPSULE]    = { CacheFlag.CACHE_FIREDELAY },
	[AstroItems.Card.LUCK_RANGE_CAPSULE]          = { CacheFlag.CACHE_LUCK, CacheFlag.CACHE_RANGE },
	[AstroItems.Card.LUCK_SHOTSPEED_CAPSULE]      = { CacheFlag.CACHE_LUCK, CacheFlag.CACHE_SHOTSPEED },
	[AstroItems.Card.LUCK_SPEED_CAPSULE]          = { CacheFlag.CACHE_LUCK, CacheFlag.CACHE_SPEED },
	[AstroItems.Card.LUCK_FIREDELAY_CAPSULE]      = { CacheFlag.CACHE_LUCK, CacheFlag.CACHE_FIREDELAY },
	[AstroItems.Card.RANGE_SHOTSPEED_CAPSULE]     = { CacheFlag.CACHE_RANGE, CacheFlag.CACHE_SHOTSPEED },
	[AstroItems.Card.RANGE_SPEED_CAPSULE]         = { CacheFlag.CACHE_RANGE, CacheFlag.CACHE_SPEED },
	[AstroItems.Card.RANGE_FIREDELAY_CAPSULE]     = { CacheFlag.CACHE_RANGE, CacheFlag.CACHE_FIREDELAY },
	[AstroItems.Card.SHOTSPEED_SPEED_CAPSULE]     = { CacheFlag.CACHE_SHOTSPEED, CacheFlag.CACHE_SPEED },
	[AstroItems.Card.SHOTSPEED_FIREDELAY_CAPSULE] = { CacheFlag.CACHE_SHOTSPEED, CacheFlag.CACHE_FIREDELAY },
	[AstroItems.Card.SPEED_FIREDELAY_CAPSULE]     = { CacheFlag.CACHE_SPEED, CacheFlag.CACHE_FIREDELAY },
}

local capsuleToHpUp       = {
	[AstroItems.Card.HEALTH_CAPSULE] = true,
	[AstroItems.Card.HEALTH_DAMAGE_CAPSULE] = true,
	[AstroItems.Card.HEALTH_LUCK_CAPSULE] = true,
	[AstroItems.Card.HEALTH_RANGE_CAPSULE] = true,
	[AstroItems.Card.HEALTH_SHOTSPEED_CAPSULE] = true,
	[AstroItems.Card.HEALTH_SPEED_CAPSULE] = true,
	[AstroItems.Card.HEALTH_FIREDELAY_CAPSULE] = true,
}

local capsuleUpgrades     = {
	[AstroItems.Card.DAMAGE_CAPSULE] = {
		AstroItems.Card.HEALTH_DAMAGE_CAPSULE,
		AstroItems.Card.LUCK_DAMAGE_CAPSULE,
		AstroItems.Card.RANGE_DAMAGE_CAPSULE,
		AstroItems.Card.SHOTSPEED_DAMAGE_CAPSULE,
		AstroItems.Card.SPEED_DAMAGE_CAPSULE,
		AstroItems.Card.FIREDELAY_DAMAGE_CAPSULE,
	},
	[AstroItems.Card.HEALTH_CAPSULE] = {
		AstroItems.Card.HEALTH_DAMAGE_CAPSULE,
		AstroItems.Card.HEALTH_LUCK_CAPSULE,
		AstroItems.Card.HEALTH_RANGE_CAPSULE,
		AstroItems.Card.HEALTH_SHOTSPEED_CAPSULE,
		AstroItems.Card.HEALTH_SPEED_CAPSULE,
		AstroItems.Card.HEALTH_FIREDELAY_CAPSULE,
	},
	[AstroItems.Card.FIREDELAY_CAPSULE] = {
		AstroItems.Card.FIREDELAY_DAMAGE_CAPSULE,
		AstroItems.Card.HEALTH_FIREDELAY_CAPSULE,
		AstroItems.Card.LUCK_FIREDELAY_CAPSULE,
		AstroItems.Card.RANGE_FIREDELAY_CAPSULE,
		AstroItems.Card.SHOTSPEED_FIREDELAY_CAPSULE,
		AstroItems.Card.SPEED_FIREDELAY_CAPSULE,
	},
	[AstroItems.Card.RANGE_CAPSULE] = {
		AstroItems.Card.RANGE_DAMAGE_CAPSULE,
		AstroItems.Card.HEALTH_RANGE_CAPSULE,
		AstroItems.Card.LUCK_RANGE_CAPSULE,
		AstroItems.Card.RANGE_SHOTSPEED_CAPSULE,
		AstroItems.Card.RANGE_SPEED_CAPSULE,
		AstroItems.Card.RANGE_FIREDELAY_CAPSULE,
	},
	[AstroItems.Card.SHOTSPEED_CAPSULE] = {
		AstroItems.Card.SHOTSPEED_DAMAGE_CAPSULE,
		AstroItems.Card.HEALTH_SHOTSPEED_CAPSULE,
		AstroItems.Card.LUCK_SHOTSPEED_CAPSULE,
		AstroItems.Card.RANGE_SHOTSPEED_CAPSULE,
		AstroItems.Card.SHOTSPEED_SPEED_CAPSULE,
		AstroItems.Card.SHOTSPEED_FIREDELAY_CAPSULE,
	},
	[AstroItems.Card.SPEED_CAPSULE] = {
		AstroItems.Card.SPEED_DAMAGE_CAPSULE,
		AstroItems.Card.HEALTH_SPEED_CAPSULE,
		AstroItems.Card.LUCK_SPEED_CAPSULE,
		AstroItems.Card.RANGE_SPEED_CAPSULE,
		AstroItems.Card.SHOTSPEED_SPEED_CAPSULE,
		AstroItems.Card.SPEED_FIREDELAY_CAPSULE,
	},
	[AstroItems.Card.LUCK_CAPSULE] = {
		AstroItems.Card.LUCK_DAMAGE_CAPSULE,
		AstroItems.Card.HEALTH_LUCK_CAPSULE,
		AstroItems.Card.LUCK_RANGE_CAPSULE,
		AstroItems.Card.LUCK_SHOTSPEED_CAPSULE,
		AstroItems.Card.LUCK_SPEED_CAPSULE,
		AstroItems.Card.LUCK_FIREDELAY_CAPSULE,
	},
}

local function GetCapsulePoolWeight(goodPool)
	local total = 0

	for _, capsule in pairs(goodPool and goodCapsuleWeights or capsuleWeights) do
		total = total + capsule
	end

	return total
end

local function GetRandomCapsule(rng, forceGood)
	local weight = GetCapsulePoolWeight(forceGood)
	local roll = rng:RandomFloat() * weight

	for capsule, weight in pairs(forceGood and goodCapsuleWeights or capsuleWeights) do
		if roll < weight then
			return capsule
		else
			roll = roll - weight
		end
	end
end

local function GetCapsuleUpgrade(pickup, rng)
	local options = capsuleUpgrades[pickup.SubType]

	if options then
		return options[rng:RandomInt(#options) + 1]
	end
end

-- Astro:AddCallback(
-- 	ModCallbacks.MC_POST_PICKUP_INIT,
-- 	---@param pickup EntityPickup
-- 	function(_, pickup)
-- 		local data = Astro:GetPersistentPickupData(pickup)

-- 		if pickup.Variant == PickupVariant.PICKUP_PILL and pickup.FrameCount == 0 and not data.IsTriedCapsule then
-- 			local pillEffect = Game():GetItemPool():GetPillEffect(pickup.SubType)

-- 			if not Astro:IsPillBlacklisted(pillEffect) then
-- 				local seed = Game():GetSeeds():GetStartSeed()

-- 				if not Astro.Data.CapsuleRNG then
-- 					Astro.Data.CapsuleRNG = RNG()
-- 					Astro.Data.CapsuleRNG:SetSeed(seed, 35)
-- 					Astro.Data.CapsuleRNGSeed = seed
-- 				end

-- 				if Astro.Data.CapsuleRNGSeed ~= seed then
-- 					Astro.Data.CapsuleRNG:SetSeed(seed, 35)
-- 				end

-- 				local rng = Astro.Data.CapsuleRNG

-- 				if rng:RandomFloat() < CAPSULE_SPAWN_CHANCE then
-- 					pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, GetRandomCapsule(rng), true, true, false);
-- 				else
-- 					data.IsTriedCapsule = true
-- 				end
-- 			end
-- 		end
-- 	end
-- )

AstroItems:AddCallback(
	ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
	---@param rng RNG
	---@param spawnPosition Vector
	function(_, rng, spawnPosition)
		local room = Game():GetRoom()
		if room:GetType() == RoomType.ROOM_DEFAULT then
			local spawnChance = CAPSULE_SPAWN_CHANCE
			local numContracts = 0

			for i = 1, Game():GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)

				numContracts = numContracts + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW)
			end

			if rng:RandomFloat() < spawnChance then
				local numToSpawn = 1

				if numContracts > 0 then
					if Isaac.GetPlayer():GetCollectibleRNG(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW):RandomFloat() < 1 / 3 then
						numToSpawn = 0
					else
						numToSpawn = 2 ^ numContracts
					end
				end

				for _ = 1, numToSpawn do
					Isaac.Spawn(5, 300, GetRandomCapsule(rng), room:FindFreePickupSpawnPosition(spawnPosition, 0, true), Vector.Zero, nil)
				end

				return true
			end
		end
	end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if isContinued then
            for i = 1, Game():GetNumPlayers() do
				local player = Isaac.GetPlayer(i - 1)
			
				local data = AstroItems:GetPersistentPlayerData(player)

				if data.damageCapsules then
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				end

				if data.tearsCapsules then
					player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
				end

				if data.rangeCapsules then
					player:AddCacheFlags(CacheFlag.CACHE_RANGE)
				end

				if data.shotspeedCapsules then
					player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
				end

				if data.speedCapsules then
					player:AddCacheFlags(CacheFlag.CACHE_SPEED)
				end

				if data.luckCapsules then
					player:AddCacheFlags(CacheFlag.CACHE_LUCK)
				end

				player:EvaluateItems()
			end
        end
    end
)


AstroItems:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	---@param player EntityPlayer
	---@param cacheFlag CacheFlag
	function(_, player, cacheFlag)
		local data = AstroItems:GetPersistentPlayerData(player)
		if data then
			local damage = data.damageCapsules or 0
			local miniDamage = data.miniDamageCapsules or 0
			-- local multiplier = mod.CalcPlayerDamageMult(player)

			player.Damage = player.Damage + 0.5 * damage -- * multiplier
			player.Damage = player.Damage + 0.25 * miniDamage -- * multiplier
		end
	end,
	CacheFlag.CACHE_DAMAGE
)

AstroItems:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	---@param player EntityPlayer
	---@param cacheFlag CacheFlag
	function(_, player, cacheFlag)
		local data = AstroItems:GetPersistentPlayerData(player)
		if data then
			local firedelay = data.tearsCapsules or 0
			local miniFiredelay = data.miniTearsCapsules or 0

			player.MaxFireDelay = AstroItems:AddTears(player.MaxFireDelay, 0.25 * firedelay)
			player.MaxFireDelay = AstroItems:AddTears(player.MaxFireDelay, 0.15 * miniFiredelay)
		end
	end,
	CacheFlag.CACHE_FIREDELAY
)

AstroItems:AddCallback(
	ModCallbacks.MC_EVALUATE_CACHE,
	---@param player EntityPlayer
	---@param cacheFlag CacheFlag
	function(_, player, cacheFlag)
		local data = AstroItems:GetPersistentPlayerData(player)
		if data then
			local range = data.rangeCapsules or 0
			local miniRange = data.miniRangeCapsules or 0

			player.TearRange = player.TearRange + 80 * range
			player.TearRange = player.TearRange + 40 * miniRange
		end
	end,
	CacheFlag.CACHE_RANGE
)

AstroItems:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,
	---@param player EntityPlayer
	---@param cacheFlag CacheFlag
	function(_, player, cacheFlag)
		local data = AstroItems:GetPersistentPlayerData(player)
		if data then
			local shotspeed = data.shotspeedCapsules or 0
			local miniShotspeed = data.miniShotspeedCapsules or 0

			player.ShotSpeed = player.ShotSpeed + 0.1 * shotspeed
			player.ShotSpeed = player.ShotSpeed + 0.1 * miniShotspeed
		end
	end,
	CacheFlag.CACHE_SHOTSPEED
)

AstroItems:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,
	---@param player EntityPlayer
	---@param cacheFlag CacheFlag
	function(_, player, cacheFlag)
		local data = AstroItems:GetPersistentPlayerData(player)
		if data then
			local speed = data.speedCapsules or 0
			local miniSpeed = data.miniSpeedCapsules or 0

			player.MoveSpeed = player.MoveSpeed + 0.1 * speed
			player.MoveSpeed = player.MoveSpeed + 0.1 * miniSpeed
		end
	end,
	CacheFlag.CACHE_SPEED
)

AstroItems:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,
	---@param player EntityPlayer
	---@param cacheFlag CacheFlag
	function(_, player, cacheFlag)
		local data = AstroItems:GetPersistentPlayerData(player)
		if data then
			local luck = data.luckCapsules or 0
			local miniLuck = data.miniLuckCapsules or 0

			player.Luck = player.Luck + 1 * luck
			player.Luck = player.Luck + 0.5 * miniLuck
		end
	end,
	CacheFlag.CACHE_LUCK
)

-- Astro:AddCallback(
-- 	ModCallbacks.MC_POST_PICKUP_UPDATE,
-- 	function(_, pickup)
-- 		if pickup.SubType >= Astro.CARDS.DAMAGE_CAPSULE and pickup.SubType <= Astro.CARDS.LUCK_CAPSULE then
-- 			if mod.AnyPlayerHasCollectible(mod.ITEMS.EMPIRIC) then
-- 				local rng = RNG()
-- 				rng:SetSeed(pickup.InitSeed, 32)
-- 				pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, GetCapsuleUpgrade(pickup, rng), true)
-- 			end
-- 		end
-- 	end,
-- 	PickupVariant.PICKUP_TAROTCARD
-- )

for capsule = AstroItems.Card.DAMAGE_CAPSULE, AstroItems.Card.SPEED_FIREDELAY_CAPSULE do
	AstroItems:AddCallback(
		ModCallbacks.MC_USE_CARD,
		function(_, card, player)
			if capsuleToTrackers[card] then
				local data = AstroItems:GetPersistentPlayerData(player)
				for _, tracker in pairs(capsuleToTrackers[card]) do
					data[tracker] = data[tracker] and data[tracker] + 1 or 1
				end
				for _, flag in pairs(capsuleToCacheFlags[card]) do
					player:AddCacheFlags(flag)
				end
				player:EvaluateItems()
			end

			if capsuleToHpUp[card] then
				player:AddMaxHearts(2)
				player:AddHearts(2)
			end

			SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
		end,
		capsule
	)
end

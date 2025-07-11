---

---@class UpgradeItem
---@field Id CollectibleType
---@field Chance number

---@type UpgradeItem[]
Astro.PLANETARIUM_UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_SOL] = { Id = Astro.Collectible.SOL_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_LUNA] = { Id = Astro.Collectible.LUNA_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_MERCURIUS] = { Id = Astro.Collectible.MERCURIUS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_VENUS] = { Id = Astro.Collectible.VENUS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_TERRA] = { Id = Astro.Collectible.TERRA_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_MARS] = { Id = Astro.Collectible.MARS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_JUPITER] = { Id = Astro.Collectible.JUPITER_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_SATURNUS] = { Id = Astro.Collectible.SATURNUS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_URANUS] = { Id = Astro.Collectible.URANUS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_NEPTUNUS] = { Id = Astro.Collectible.NEPTUNUS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_PLUTO] = { Id = Astro.Collectible.PLUTO_EX, Chance = 0 },
    -- 위의 행성은 별도의 업그레이드 로직을 따름
    [CollectibleType.COLLECTIBLE_AQUARIUS] = { Id = Astro.Collectible.AQUARIUS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_PISCES] = { Id = Astro.Collectible.PISCES_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_ARIES] = { Id = Astro.Collectible.ARIES_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_TAURUS] = { Id = Astro.Collectible.TAURUS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_GEMINI] = { Id = Astro.Collectible.GEMINI_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_CANCER] = { Id = Astro.Collectible.CANCER_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_LEO] = { Id = Astro.Collectible.LEO_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_VIRGO] = { Id = Astro.Collectible.VIRGO_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_LIBRA] = { Id = Astro.Collectible.LIBRA_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_SCORPIO] = { Id = Astro.Collectible.SCORPIO_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_SAGITTARIUS] = { Id = Astro.Collectible.SAGITTARIUS_EX, Chance = 0 },
    [CollectibleType.COLLECTIBLE_CAPRICORN] = { Id = Astro.Collectible.CAPRICORN_EX, Chance = 0 },
    -- 위의 별자리는 자동으로 업그레이드 되지 않음
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = { Id = Astro.Collectible.ASTRO_SACRED_HEART, Chance = 0.2 },
    [CollectibleType.COLLECTIBLE_GODHEAD] = { Id = Astro.Collectible.ASTRO_GODHEAD, Chance = 0.5 },
    [CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM] = { Id = Astro.Collectible.ASTRO_STAR_OF_BETHLEHEM, Chance = 0.6 },
    [CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER] = { Id = Astro.Collectible.WE_NEED_TO_GO_DEEPER_ASTRO, Chance = 0.2 },

}

---@type UpgradeItem[]
Astro.PLANET_UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_SOL] = { Id = Astro.Collectible.SOL_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_LUNA] = { Id = Astro.Collectible.LUNA_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_MERCURIUS] = { Id = Astro.Collectible.MERCURIUS_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_VENUS] = { Id = Astro.Collectible.VENUS_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_TERRA] = { Id = Astro.Collectible.TERRA_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_MARS] = { Id = Astro.Collectible.MARS_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_JUPITER] = { Id = Astro.Collectible.JUPITER_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_SATURNUS] = { Id = Astro.Collectible.SATURNUS_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_URANUS] = { Id = Astro.Collectible.URANUS_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_NEPTUNUS] = { Id = Astro.Collectible.NEPTUNUS_EX, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_PLUTO] = { Id = Astro.Collectible.PLUTO_EX, Chance = 0.3 },
}

---@type UpgradeItem[]
Astro.UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_DEATHS_LIST] = { Id = Astro.Collectible.BLACK_LIST, Chance = 0.2 },
    [CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID] = { Id = Astro.Collectible.MAW_OF_THE_VOID_EX, Chance = 0.5 },
    [CollectibleType.COLLECTIBLE_BLACK_CANDLE] = { Id = Astro.Collectible.PURPLE_CANDLE, Chance = 0.5 },
    [CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR] = { Id = Astro.Collectible.SUPER_ROCKET_IN_A_JAR, Chance = 0.6 },
    [CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE] = { Id = Astro.Collectible.STEAM_BUNDLE, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_LIL_CHEST] = { Id = Astro.Collectible.BIG_CHEST, Chance = 0.3 },
    [CollectibleType.COLLECTIBLE_CRICKETS_HEAD] = { Id = Astro.Collectible.MAXS_HEAD, Chance = 0.3 }
}

---

local function HasUpgradedPlanet()
    for _, collectible in pairs(Astro.PLANET_UPGRADE_LIST) do
        if Astro:HasCollectible(collectible.Id) then
            return true
        end
    end

    return false
end

local function TryUpgradePlanet(selectedCollectible, seed)
    local upgradeData = Astro.PLANET_UPGRADE_LIST[selectedCollectible]

    if upgradeData and upgradeData.Chance ~= 0 and not HasUpgradedPlanet() then
        local room = Game():GetRoom()
        local roomType = room:GetType()

        if roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET or roomType == RoomType.ROOM_ULTRASECRET then
            local rng = RNG()
            rng:SetSeed(seed, 35)

            if rng:RandomFloat() < 1 then
                return upgradeData.Id
            end
        end
    end

    return nil
end

local function TryUpgrade(selectedCollectible, seed)
    local upgradeData = Astro.UPGRADE_LIST[selectedCollectible] or Astro.PLANETARIUM_UPGRADE_LIST[selectedCollectible]

    if upgradeData and upgradeData.Chance ~= 0 then
        local rng = RNG()
        rng:SetSeed(seed, 35)

        if rng:RandomFloat() < 1 then
            return upgradeData.Id
        end
    end

    return nil
end

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        Astro:AddRerollCondition(
            function(selectedCollectible, itemPoolType, decrease, seed)
                local upgradeId = TryUpgradePlanet(selectedCollectible, seed)

                if upgradeId then
                    return {
                        reroll = true,
                        newItem = upgradeId,
                        modifierName = "Planet Upgrade"
                    }
                end
        
                return false
            end
        )

        Astro:AddRerollCondition(
            function(selectedCollectible, itemPoolType, decrease, seed)
                local upgradeId = TryUpgrade(selectedCollectible, seed)

                if upgradeId then
                    return {
                        reroll = true,
                        newItem = upgradeId,
                        modifierName = "Item Upgrade"
                    }
                end

                return false
            end
        )
    end
)

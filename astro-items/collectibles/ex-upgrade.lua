---

local UPGRADE_CHANCE = 0.5

AstroItems.ZODIAC_UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_AQUARIUS] = AstroItems.Collectible.AQUARIUS_EX,
    [CollectibleType.COLLECTIBLE_PISCES] = AstroItems.Collectible.PISCES_EX,
    [CollectibleType.COLLECTIBLE_ARIES] = AstroItems.Collectible.ARIES_EX,
    [CollectibleType.COLLECTIBLE_TAURUS] = AstroItems.Collectible.TAURUS_EX,
    [CollectibleType.COLLECTIBLE_GEMINI] = AstroItems.Collectible.GEMINI_EX,
    [CollectibleType.COLLECTIBLE_CANCER] = AstroItems.Collectible.CANCER_EX,
    [CollectibleType.COLLECTIBLE_LEO] = AstroItems.Collectible.LEO_EX,
    [CollectibleType.COLLECTIBLE_VIRGO] = AstroItems.Collectible.VIRGO_EX,
    [CollectibleType.COLLECTIBLE_LIBRA] = AstroItems.Collectible.LIBRA_EX,
    [CollectibleType.COLLECTIBLE_SCORPIO] = AstroItems.Collectible.SCORPIO_EX,
    [CollectibleType.COLLECTIBLE_SAGITTARIUS] = AstroItems.Collectible.SAGITTARIUS_EX,
    [CollectibleType.COLLECTIBLE_CAPRICORN] = AstroItems.Collectible.CAPRICORN_EX
}

AstroItems.PLANET_UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_SOL] = AstroItems.Collectible.SOL_EX,
    [CollectibleType.COLLECTIBLE_LUNA] = AstroItems.Collectible.LUNA_EX,
    [CollectibleType.COLLECTIBLE_MERCURIUS] = AstroItems.Collectible.MERCURIUS_EX,
    [CollectibleType.COLLECTIBLE_VENUS] = AstroItems.Collectible.VENUS_EX,
    [CollectibleType.COLLECTIBLE_TERRA] = AstroItems.Collectible.TERRA_EX,
    [CollectibleType.COLLECTIBLE_MARS] = AstroItems.Collectible.MARS_EX,
    [CollectibleType.COLLECTIBLE_JUPITER] = AstroItems.Collectible.JUPITER_EX,
    [CollectibleType.COLLECTIBLE_SATURNUS] = AstroItems.Collectible.SATURNUS_EX,
    [CollectibleType.COLLECTIBLE_URANUS] = AstroItems.Collectible.URANUS_EX,
    [CollectibleType.COLLECTIBLE_NEPTUNUS] = AstroItems.Collectible.NEPTUNUS_EX,
    [CollectibleType.COLLECTIBLE_PLUTO] = AstroItems.Collectible.PLUTO_EX
}

AstroItems.UPGRADE_LIST = {}
for k, v in pairs(AstroItems.ZODIAC_UPGRADE_LIST) do AstroItems.UPGRADE_LIST[k] = v end
for k, v in pairs(AstroItems.PLANET_UPGRADE_LIST) do AstroItems.UPGRADE_LIST[k] = v end

---

-- 현재 방에서 시도한 아이템 리스트
local currentRoomData = {}

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        currentRoomData = {}
    end
)

---@param table table
---@param key any
local function HasKey(table, key)
    for k, v in pairs(table) do
        if k == key then
            return true
        end
    end

    return false
end

local function HasUpgradedCollectible()
    for _, collectible in pairs(AstroItems.PLANET_UPGRADE_LIST) do
        if AstroItems:HasCollectible(collectible) then
            return true
        end
    end

    return false
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if HasKey(AstroItems.PLANET_UPGRADE_LIST, selectedCollectible) and AstroItems:FindIndex(currentRoomData, selectedCollectible) == -1 and not HasUpgradedCollectible() then
            local rng = RNG()
            rng:SetSeed(seed, 35)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                table.insert(currentRoomData, selectedCollectible)
                return AstroItems.PLANET_UPGRADE_LIST[selectedCollectible]
            end
        end
    end
)

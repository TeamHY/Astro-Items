---

local UPGRADE_CHANCE = 0.3

Astro.ZODIAC_UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_AQUARIUS] = Astro.Collectible.AQUARIUS_EX,
    [CollectibleType.COLLECTIBLE_PISCES] = Astro.Collectible.PISCES_EX,
    [CollectibleType.COLLECTIBLE_ARIES] = Astro.Collectible.ARIES_EX,
    [CollectibleType.COLLECTIBLE_TAURUS] = Astro.Collectible.TAURUS_EX,
    [CollectibleType.COLLECTIBLE_GEMINI] = Astro.Collectible.GEMINI_EX,
    [CollectibleType.COLLECTIBLE_CANCER] = Astro.Collectible.CANCER_EX,
    [CollectibleType.COLLECTIBLE_LEO] = Astro.Collectible.LEO_EX,
    [CollectibleType.COLLECTIBLE_VIRGO] = Astro.Collectible.VIRGO_EX,
    [CollectibleType.COLLECTIBLE_LIBRA] = Astro.Collectible.LIBRA_EX,
    [CollectibleType.COLLECTIBLE_SCORPIO] = Astro.Collectible.SCORPIO_EX,
    [CollectibleType.COLLECTIBLE_SAGITTARIUS] = Astro.Collectible.SAGITTARIUS_EX,
    [CollectibleType.COLLECTIBLE_CAPRICORN] = Astro.Collectible.CAPRICORN_EX
}

Astro.PLANET_UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_SOL] = Astro.Collectible.SOL_EX,
    [CollectibleType.COLLECTIBLE_LUNA] = Astro.Collectible.LUNA_EX,
    [CollectibleType.COLLECTIBLE_MERCURIUS] = Astro.Collectible.MERCURIUS_EX,
    [CollectibleType.COLLECTIBLE_VENUS] = Astro.Collectible.VENUS_EX,
    [CollectibleType.COLLECTIBLE_TERRA] = Astro.Collectible.TERRA_EX,
    [CollectibleType.COLLECTIBLE_MARS] = Astro.Collectible.MARS_EX,
    [CollectibleType.COLLECTIBLE_JUPITER] = Astro.Collectible.JUPITER_EX,
    [CollectibleType.COLLECTIBLE_SATURNUS] = Astro.Collectible.SATURNUS_EX,
    [CollectibleType.COLLECTIBLE_URANUS] = Astro.Collectible.URANUS_EX,
    [CollectibleType.COLLECTIBLE_NEPTUNUS] = Astro.Collectible.NEPTUNUS_EX,
    [CollectibleType.COLLECTIBLE_PLUTO] = Astro.Collectible.PLUTO_EX
}

Astro.UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = Astro.Collectible.ASTRO_SACRED_HEART,
    [CollectibleType.COLLECTIBLE_GODHEAD] = Astro.Collectible.ASTRO_GODHEAD,
}

for k, v in pairs(Astro.ZODIAC_UPGRADE_LIST) do Astro.UPGRADE_LIST[k] = v end
for k, v in pairs(Astro.PLANET_UPGRADE_LIST) do Astro.UPGRADE_LIST[k] = v end

---

-- 현재 방에서 시도한 아이템 리스트
local currentRoomData = {}

Astro:AddCallback(
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
    for _, collectible in pairs(Astro.PLANET_UPGRADE_LIST) do
        if Astro:HasCollectible(collectible) then
            return true
        end
    end

    return false
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if HasKey(Astro.PLANET_UPGRADE_LIST, selectedCollectible) and Astro:FindIndex(currentRoomData, selectedCollectible) == -1 and not HasUpgradedCollectible() then
            local room = Game():GetRoom()
            local roomType = room:GetType()

            if roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET or roomType == RoomType.ROOM_ULTRASECRET then
                local rng = RNG()
                rng:SetSeed(seed, 35)

                if rng:RandomFloat() < UPGRADE_CHANCE then
                    table.insert(currentRoomData, selectedCollectible)
                    return Astro.PLANET_UPGRADE_LIST[selectedCollectible]
                end
            end
        end
    end
)

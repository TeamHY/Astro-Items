---

local UPGRADE_CHANCE = 0.5

local UPGRADE_LIST = {
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

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if HasKey(UPGRADE_LIST, selectedCollectible) and AstroItems:FindIndex(currentRoomData, selectedCollectible) == -1 then
            local rng = RNG()
            rng:SetSeed(seed, 35)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                table.insert(currentRoomData, selectedCollectible)
                return UPGRADE_LIST[selectedCollectible]
            end
        end
    end
)

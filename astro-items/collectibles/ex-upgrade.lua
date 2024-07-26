---

local UPGRADE_CHANCE = 0.5

local UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_SOL] = AstroItems.Collectible.SOL_EX,
    [CollectibleType.COLLECTIBLE_LUNA] = AstroItems.Collectible.LUNA_EX,
    [CollectibleType.COLLECTIBLE_MERCURIUS] = AstroItems.Collectible.MERCURIUS_EX,
}

---

-- 현재 방에서 시도한 아이템 리스트
local currentRoomData = {}

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        currentRoomData = {}
        print("adsf")
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

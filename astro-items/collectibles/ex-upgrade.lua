---

local UPGRADE_CHANCE = 0.5

local UPGRADE_LIST = {
    [CollectibleType.COLLECTIBLE_SOL] = AstroItems.Collectible.SOL_EX
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

---@param list table
---@param key any
local function HasKey(list, key)
    for k, v in pairs(list) do
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
        if HasKey(UPGRADE_LIST, selectedCollectible) and not AstroItems:FindIndex(currentRoomData, selectedCollectible) then
            local rng = RNG()
            rng:SetSeed(seed, 35)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                table.insert(currentRoomData, selectedCollectible)
                return UPGRADE_LIST[selectedCollectible]
            end
        end
    end
)

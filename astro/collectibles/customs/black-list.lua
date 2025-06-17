---

local UPGRADE_CHANCE = 0.2

---

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.BLACK_LIST = Isaac.GetItemIdByName("Black List")

local RoomTypeList = {
    [RoomType.ROOM_TREASURE] = true,
}

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BLACK_LIST,
        "블랙 리스트",
        "...",
        "{{Collectible530}}Death's List 효과가 적용됩니다." ..
        "#!!! {{ColorRed}}테스트: 보물방 입장 시 버튼이 생성됩니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if selectedCollectible == CollectibleType.COLLECTIBLE_DEATHS_LIST then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BLACK_LIST)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                return Astro.Collectible.BLACK_LIST
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local room = Game():GetRoom()
        local roomType = room:GetType()
        
        if room:IsFirstVisit() and RoomTypeList[roomType] then
            for i = 0, Game():GetNumPlayers() - 1 do
                local player = Isaac.GetPlayer(i)
                
                if player:HasCollectible(Astro.Collectible.BLACK_LIST) then
                    room:SpawnGridEntity(room:GetGridIndex(room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0)), GridEntityType.GRID_PRESSURE_PLATE, 0, 0, 0)
                    break
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_DEATHS_LIST, player:HasCollectible(Astro.Collectible.BLACK_LIST) and 1 or 0, "ASTRO_BLACK_LIST")
    end
)

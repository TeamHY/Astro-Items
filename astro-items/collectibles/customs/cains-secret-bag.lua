AstroItems.Collectible.CAINS_SECRET_BAG = Isaac.GetItemIdByName("Cain's Secret Bag")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.CAINS_SECRET_BAG, "케인의 비밀 주머니", "...", "사용 시 소지한 아이템 중 하나를 제거합니다. 제거된 아이템과 행운방 아이템 2개를 소환합니다. 하나를 선택하면 나머지는 사라집니다.#스테이지 진입 시 쿨타임이 채워집니다.#!!! 비밀방에서는 사용할 수 없습니다.")
end

local banRooms = {
    RoomType.ROOM_SECRET,
}

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == AstroItems.Collectible.CAINS_SECRET_BAG then
                    -- if player:GetPlayerType() == AstroItems.Players.WATER_ENCHANTRESS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                    --     player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    --     player:SetActiveCharge(100, j)
                    --     player:RemoveCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    -- else
                        player:SetActiveCharge(50, j)
                    -- end
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        if AstroItems:FindIndex(banRooms, Game():GetLevel():GetCurrentRoom():GetType()) ~= -1 then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local inventory = AstroItems:getPlayerInventory(playerWhoUsedItem, false)
        local rng = playerWhoUsedItem:GetCollectibleRNG(AstroItems.Collectible.CAINS_SECRET_BAG)
        local optionsPickupIndex = AstroItems.Collectible.CAINS_SECRET_BAG * 10000

        local hadCollectable = AstroItems:GetRandomCollectibles(inventory, rng, 1, AstroItems.Collectible.CAINS_SECRET_BAG, true)[1]

        if hadCollectable ~= nil then
            playerWhoUsedItem:RemoveCollectible(hadCollectable)
            AstroItems:SpawnCollectible(hadCollectable, playerWhoUsedItem.Position, optionsPickupIndex)
        end

        AstroItems:SpawnCollectible(AstroItems:GetBarrenPoolCollectible(rng), playerWhoUsedItem.Position, optionsPickupIndex)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.CAINS_SECRET_BAG
)

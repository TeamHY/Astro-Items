Astro.Collectible.CAINS_SECRET_BAG = Isaac.GetItemIdByName("Cain's Secret Bag")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.CAINS_SECRET_BAG, "카인의 비밀 주머니", "...", "{{SuperSecretRoom}} 일급비밀방에서 사용 시 소지한 아이템 중 하나를 제거하며, 제거된 아이템과 {{IsaacsRoom}}행운방 아이템 2개를 소환합니다.#하나를 선택하면 나머지는 사라집니다.#스테이지 진입 시 충전량이 채워집니다.")
end

-- local banRooms = {
--     RoomType.ROOM_SECRET,
-- }

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == Astro.Collectible.CAINS_SECRET_BAG then
                    -- if player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
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

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        -- if Astro:FindIndex(banRooms, Game():GetLevel():GetCurrentRoom():GetType()) ~= -1 then
        --     return {
        --         Discharge = false,
        --         Remove = false,
        --         ShowAnim = false,
        --     }
        -- end

        if Game():GetLevel():GetCurrentRoom():GetType() ~= RoomType.ROOM_SUPERSECRET then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local inventory = Astro:getPlayerInventory(playerWhoUsedItem, false)
        local rng = playerWhoUsedItem:GetCollectibleRNG(Astro.Collectible.CAINS_SECRET_BAG)
        local optionsPickupIndex = Astro.Collectible.CAINS_SECRET_BAG * 10000

        local hadCollectable = Astro:GetRandomCollectibles(inventory, rng, 1, Astro.Collectible.CAINS_SECRET_BAG, true)[1]

        if hadCollectable ~= nil then
            playerWhoUsedItem:RemoveCollectible(hadCollectable)
            Astro:SpawnCollectible(hadCollectable, playerWhoUsedItem.Position, optionsPickupIndex)
        end

        Astro:SpawnCollectible(Astro:GetBarrenPoolCollectible(rng), playerWhoUsedItem.Position, optionsPickupIndex)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.CAINS_SECRET_BAG
)

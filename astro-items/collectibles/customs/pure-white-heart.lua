AstroItems.Collectible.PURE_WHITE_HEART = Isaac.GetItemIdByName("Pure White Heart")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.PURE_WHITE_HEART,
        "순백의 심장",
        "...",
        "!!! 효과가 발동한 뒤 사라집니다.#소지한 상태에서 {{BossRoom}}보스방 클리어 시 현재 소지중인 아이템 1개(랜덤) + , {{AngelRoom}}천사방 아이템 2개를 소환합니다. 하나를 선택하면 나머지는 사라집니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function()
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.PURE_WHITE_HEART) and currentRoom:GetType() == RoomType.ROOM_BOSS then
                local rng = player:GetCollectibleRNG(AstroItems.Collectible.PURE_WHITE_HEART)
                local inventory = AstroItems:getPlayerInventory(player, false)
                local itemPool = Game():GetItemPool()

                local listToRemove =
                    AstroItems:GetRandomCollectibles(inventory, rng, 1, AstroItems.Collectible.PURE_WHITE_HEART, true)

                for _, value in ipairs(listToRemove) do
                    player:RemoveCollectible(value)
                    AstroItems:SpawnCollectible(value, player.Position, AstroItems.Collectible.PURE_WHITE_HEART)
                end

                AstroItems:SpawnCollectible(
                    itemPool:GetCollectible(ItemPoolType.POOL_ANGEL, true, currentRoom:GetSpawnSeed()),
                    player.Position,
                    AstroItems.Collectible.PURE_WHITE_HEART
                )
                AstroItems:SpawnCollectible(
                    itemPool:GetCollectible(ItemPoolType.POOL_ANGEL, true, currentRoom:GetSpawnSeed()),
                    player.Position,
                    AstroItems.Collectible.PURE_WHITE_HEART
                )

                player:RemoveCollectible(AstroItems.Collectible.PURE_WHITE_HEART)
            end
        end
    end
)

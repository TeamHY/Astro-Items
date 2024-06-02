local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.TRINITY = Isaac.GetItemIdByName("Trinity")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.TRINITY, "삼위일체", "...", "{{BossRoom}}보스방 클리어 시 {{Collectible333}}The Mind, {{Collectible334}}The Body, {{Collectible335}}The Soul을 제거합니다.#스테이지를 넘어갈 때마다 소지된 아이템 중 하나를 제거합니다. 제거된 아이템과 {{Collectible333}}The Mind, {{Collectible334}}The Body, {{Collectible335}}The Soul 중 하나를 소환합니다. 하나를 선택하면 나머지는 사라집니다.#!!! 이번 게임에서 {{Collectible333}}The Mind, {{Collectible334}}The Body, {{Collectible335}}The Soul이 등장하지 않습니다.")
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()

        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_MIND)
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_BODY)
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SOUL)
    end,
    AstroItems.Collectible.TRINITY
)

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()

        if currentRoom:GetType() == RoomType.ROOM_BOSS then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(AstroItems.Collectible.TRINITY) then
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_MIND)
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_BODY)
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_SOUL)
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.TRINITY) then
                local inventory = AstroItems:getPlayerInventory(player, false)
                local rng = player:GetCollectibleRNG(AstroItems.Collectible.TRINITY)

                local hadCollectable = AstroItems:GetRandomCollectibles(inventory, rng, 1, AstroItems.Collectible.TRINITY, true)

                if hadCollectable[1] ~= nil then
                    player:RemoveCollectible(hadCollectable[1])
                    AstroItems:SpawnCollectible(hadCollectable[1], player.Position, AstroItems.Collectible.TRINITY)
                end

                local random = rng:RandomInt(3)

                if random == 0 then
                    AstroItems:SpawnCollectible(CollectibleType.COLLECTIBLE_MIND, player.Position, AstroItems.Collectible.TRINITY)
                elseif random == 1 then
                    AstroItems:SpawnCollectible(CollectibleType.COLLECTIBLE_BODY, player.Position, AstroItems.Collectible.TRINITY)
                else
                    AstroItems:SpawnCollectible(CollectibleType.COLLECTIBLE_SOUL, player.Position, AstroItems.Collectible.TRINITY)
                end
            end
        end
    end
)

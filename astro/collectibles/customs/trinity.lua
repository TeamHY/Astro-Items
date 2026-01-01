local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.TRINITY = Isaac.GetItemIdByName("Trinity")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.TRINITY,
                "삼위일체",
                "성부와 성자와 성령의 이름으로",
                "!!! 획득 이후 {{Collectible333}}The Mind, {{Collectible334}}The Body, {{Collectible335}}The Soul 미등장" ..
                "#{{BossRoom}} 보스방 클리어 시 {{Collectible333}}/{{Collectible334}}/{{Collectible335}}을 제거합니다." ..
                "#스테이지를 넘어갈 때마다 소지중인 아이템 중 하나를 제거하며;" ..
                "#{{ArrowGrayRight}} 제거된 아이템과 {{Collectible333}}/{{Collectible334}}/{{Collectible335}} 중 하나를 소환합니다." ..
                "#{{ArrowGrayRight}} 소환된 아이템 중 하나를 선택하면 나머지는 사라집니다."
            )
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()

        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_MIND)
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_BODY)
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SOUL)
    end,
    Astro.Collectible.TRINITY
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()

        if currentRoom:GetType() == RoomType.ROOM_BOSS then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.TRINITY) then
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_MIND)
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_BODY)
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_SOUL)
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.TRINITY) then
                local inventory = Astro:getPlayerInventory(player, false)
                local rng = player:GetCollectibleRNG(Astro.Collectible.TRINITY)

                local hadCollectable = Astro:GetRandomCollectibles(inventory, rng, 1, Astro.Collectible.TRINITY, true)

                if hadCollectable[1] ~= nil then
                    player:RemoveCollectible(hadCollectable[1])
                    Astro:SpawnCollectible(hadCollectable[1], player.Position, Astro.Collectible.TRINITY)
                end

                local random = rng:RandomInt(3)

                if random == 0 then
                    Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_MIND, player.Position, Astro.Collectible.TRINITY)
                elseif random == 1 then
                    Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_BODY, player.Position, Astro.Collectible.TRINITY)
                else
                    Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_SOUL, player.Position, Astro.Collectible.TRINITY)
                end
            end
        end
    end
)

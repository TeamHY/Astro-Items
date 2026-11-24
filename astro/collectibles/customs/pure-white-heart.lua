Astro.Collectible.PURE_WHITE_HEART = Isaac.GetItemIdByName("Pure White Heart")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.PURE_WHITE_HEART,
                "순백의 심장",
                "시작부터 마음 속에 있으니",
                "!!! 효과를 발동한 후 이 아이템은 사라집니다." ..
                "#{{EternalHeart}} 이터널하트 1-3개를 드랍합니다." ..
                "#소지중일 때 {{BossRoom}}보스방 클리어 시 소지중인 아이템 중 1개와 {{AngelRoom}}천사방 아이템 2개를 소환합니다." ..
                "#{{ArrowGrayRight}} 소환된 아이템 중 하나를 선택하면 나머지는 사라집니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.PURE_WHITE_HEART,
                "Pure White Heart", "",
                "!!! Disappears after activation" ..
                "#{{EternalHeart}} Spawns 1-3 Eternal Hearts" ..
                "#Spawns 1 held item and 2 {{AngelRoom}} Angel items on {{BossRoom}} boss clear" ..
                "#Choose one; the rest disappear",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function()
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.PURE_WHITE_HEART) and currentRoom:GetType() == RoomType.ROOM_BOSS then
                local rng = player:GetCollectibleRNG(Astro.Collectible.PURE_WHITE_HEART)
                local inventory = Astro:getPlayerInventory(player, false)
                local itemPool = Game():GetItemPool()

                local listToRemove =
                    Astro:GetRandomCollectibles(inventory, rng, 1, Astro.Collectible.PURE_WHITE_HEART, true)

                for _, value in ipairs(listToRemove) do
                    player:RemoveCollectible(value)
                    Astro:SpawnCollectible(value, player.Position, Astro.Collectible.PURE_WHITE_HEART)
                end

                Astro:SpawnCollectible(
                    itemPool:GetCollectible(ItemPoolType.POOL_ANGEL, true, currentRoom:GetSpawnSeed()),
                    player.Position,
                    Astro.Collectible.PURE_WHITE_HEART
                )
                Astro:SpawnCollectible(
                    itemPool:GetCollectible(ItemPoolType.POOL_ANGEL, true, currentRoom:GetSpawnSeed()),
                    player.Position,
                    Astro.Collectible.PURE_WHITE_HEART
                )

                player:RemoveCollectible(Astro.Collectible.PURE_WHITE_HEART)
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.PURE_WHITE_HEART) then
            local rng = player:GetCollectibleRNG(Astro.Collectible.PURE_WHITE_HEART)

            for _ = 1, rng:RandomInt(3) + 1 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, Isaac.GetFreeNearPosition(player.Position, 40), Vector(0, 0), player)
            end
        end
    end,
    Astro.Collectible.PURE_WHITE_HEART
)

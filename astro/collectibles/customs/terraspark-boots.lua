Astro.Collectible.TERRASPARK_BOOTS = Isaac.GetItemIdByName("Terraspark Boots")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.TERRASPARK_BOOTS,
        "테라스파크 부츠",
        "영웅의 부츠",
        "{{SpeedSmall}} 클리어한 방에서 이동속도 +2" ..
        "#{{SpeedSmall}} 클리어하지 않은 방에서 이동속도 -0.3"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        ---@type EntityPlayer
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.TERRASPARK_BOOTS) then
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        ---@type EntityPlayer
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.TERRASPARK_BOOTS) then
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.TERRASPARK_BOOTS) then
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            if currentRoom:IsClear() then
                player.MoveSpeed = player.MoveSpeed + 2
            else
                player.MoveSpeed = player.MoveSpeed - 0.3
            end
        end
    end,
    CacheFlag.CACHE_SPEED
)

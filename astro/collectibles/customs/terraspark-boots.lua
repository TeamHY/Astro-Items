Astro.Collectible.TERRASPARK_BOOTS = Isaac.GetItemIdByName("Terraspark Boots")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.TERRASPARK_BOOTS, "테라스파크 부츠", "...", "방이 클리어 상태일 시 {{Speed}}이동 속도가 2 증가합니다.#방이 클리어 상태가 아닐 시 {{Speed}}이동 속도가 0.3 감소합니다.")
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

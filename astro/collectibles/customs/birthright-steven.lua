Astro.Collectible.BIRTHRIGHT_STEVEN = Isaac.GetItemIdByName("Birthright - Steven")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_STEVEN,
                "생득권 - 스티븐",
                "...",
                "보스방에서 {{Collectible100}}Little Steven만 등장합니다." ..
                "#2개 이상 중첩 시 {{Collectible100}}Little Steven이 추가로 소환됩니다."
            )
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    CallbackPriority.IMPORTANT,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        local room = Game():GetRoom()
        
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_STEVEN) and room:GetType() == RoomType.ROOM_BOSS then                
                if selectedCollectible ~= CollectibleType.COLLECTIBLE_LITTLE_STEVEN then
                    local newCollectable = CollectibleType.COLLECTIBLE_LITTLE_STEVEN
                    print("Birthright - Steven: " .. selectedCollectible .. " -> " .. newCollectable)

                    return newCollectable
                end
            end
        end
    end
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
                local num = player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_STEVEN)

                if num >= 2 then
                    for _ = 1, num - 1 do
                        Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_LITTLE_STEVEN, player.Position)
                    end
                end
            end
        end
    end
)

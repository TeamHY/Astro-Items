---

local MAXIMUM_ITEM_LIMIT = 3

---

Astro.Collectible.BIRTHRIGHT_STEVEN = Isaac.GetItemIdByName("Steven's Frame")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_STEVEN,
                "스티븐의 액자",
                "그는 살아 있다",
                "!!! 최초 획득 시 {{Trinket57}}???'s Soul 1개 소환" ..
                "#{{BossRoom}} 보스방 클리어 시 {{Collectible100}}Little Steven을 획득합니다." ..
                "#!!! 소지중인 Little Steven이 3개 이상일 경우 이 아이템은 제거됩니다.",
                -- 중첩 시
                "중첩된 수만큼 Little Steven 추가 획득"
            )
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

                for _ = 1, num do
                    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LITTLE_STEVEN) >= MAXIMUM_ITEM_LIMIT then
                        break
                    end

                    player:AddCollectible(CollectibleType.COLLECTIBLE_LITTLE_STEVEN)
                end

                if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LITTLE_STEVEN) >= MAXIMUM_ITEM_LIMIT then
                    Astro:RemoveAllCollectible(player, Astro.Collectible.BIRTHRIGHT_STEVEN)
                end
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.BIRTHRIGHT_STEVEN) then
            Astro:SpawnTrinket(TrinketType.TRINKET_SOUL, player.Position)
        end
    end,
    Astro.Collectible.BIRTHRIGHT_STEVEN
)

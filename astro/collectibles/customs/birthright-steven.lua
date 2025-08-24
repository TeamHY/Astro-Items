local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_STEVEN = Isaac.GetItemIdByName("Birthright - Steven")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_STEVEN,
                "스티븐의 생득권",
                "그는 살아 있다",
                "{{BossRoom}} 보스방 보상 아이템이 {{Collectible100}}Little Steven으로 고정됩니다." ..
                "#!!! 소지중인 Little Steven이 4개 이상일 경우 이 아이템은 제거됩니다.",
                -- 중첩 시
                "중첩된 수만큼 Little Steven 추가 소환"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                local room = Game():GetRoom()
                
                if Astro:HasCollectible(Astro.Collectible.BIRTHRIGHT_STEVEN) and room:GetType() == RoomType.ROOM_BOSS and selectedCollectible ~= CollectibleType.COLLECTIBLE_LITTLE_STEVEN then
                    return {
                        reroll = true,
                        newItem = CollectibleType.COLLECTIBLE_LITTLE_STEVEN,
                        modifierName = "Birthright - Steven"
                    }
                end
        
                return false
            end
        )
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

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LITTLE_STEVEN) >= 4 then
            Astro:RemoveAllCollectible(player, Astro.Collectible.BIRTHRIGHT_STEVEN)
        end
    end,
    CollectibleType.COLLECTIBLE_LITTLE_STEVEN
)

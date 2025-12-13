Astro.Collectible.ALCOHOL_BOTTLE = Isaac.GetItemIdByName("Alcohol Bottle")

local ALCOHOL_MULTIPLIER = 1.2
local ALCOHOL_CHANCE = 0.1115

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ALCOHOL_BOTTLE,
                "술병",
                "그의 낙",
                "↑ {{TearsSmall}}연사 배율 x1.2" ..
                "#클리어한 방에 다시 입장할 때 " .. string.format("%.2f", ALCOHOL_CHANCE * 100) .. "% 확률로 그 방을 다시 시작합니다.",
                -- 중첩 시
                "연사 배율 중첩 가능#중첩 시 방 재시작 확률 증가"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.ALCOHOL_BOTTLE,
                "Alcohol Bottle",
                "",
                "↑ {{Tears}} x1.2 Tears multiplier" ..
                "#" .. string.format("%.2f", ALCOHOL_CHANCE * 100) .. "% chance to restart a room and respawn all enemies when entering a cleared room",
                -- Stacks
                "Tears multiplier stackable#Increases chance of restarting the room when stacked",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        local game = Game()
        local level = game:GetLevel()
        local currentRoom = level:GetCurrentRoom()

        if not currentRoom:IsClear() then return end

        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.ALCOHOL_BOTTLE) then
                local num = player:GetCollectibleNum(Astro.Collectible.ALCOHOL_BOTTLE)
                local chance = ALCOHOL_CHANCE * num

                local rng = player:GetCollectibleRNG(Astro.Collectible.ALCOHOL_BOTTLE)
                local float = rng:RandomFloat()
                
                if float < chance then
                    currentRoom:RespawnEnemies()
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.ALCOHOL_BOTTLE) then
            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = (player.MaxFireDelay + 1) / (ALCOHOL_MULTIPLIER ^ player:GetCollectibleNum(Astro.Collectible.ALCOHOL_BOTTLE)) - 1
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local alcoholNum = player:GetCollectibleNum(Astro.Collectible.ALCOHOL_BOTTLE)
        local gbOffset = math.max(0.6, 1 - (0.2 * alcoholNum))

        player:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
        player:SetColor(Color(1, gbOffset, gbOffset, 1), -1, 1, false, false)
    end,
    Astro.Collectible.ALCOHOL_BOTTLE
)
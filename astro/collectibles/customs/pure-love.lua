local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.PURE_LOVE = Isaac.GetItemIdByName("Pure Love")

local useSound = Isaac.GetSoundIdByName('Destroyed')
local useSoundVolume = 1 -- 0 ~ 1

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.PURE_LOVE,
                "순애",
                "야곱의 사랑",
                "!!! {{SuperSecretRoom}}일급비밀방에서만 사용 가능" ..
                "#사용 시:" ..
                "#{{ArrowGrayRight}} {{LuckSmall}}행운 -1"..
                "#{{ArrowGrayRight}} 소지중인 아이템 1개와 {{Quality3}}/{{Quality4}}등급의 아이템을 하나 소환합니다." ..
                "#{{ArrowGrayRight}} 소환된 아이템 중 하나를 선택하면 나머지는 사라집니다." ..
                "#{{SuperSecretRoom}} 1스테이지 맵에 일급비밀방 위치가 표시됩니다."..
                "#스테이지 진입 시 충전량이 모두 채워집니다."
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.PURE_LOVE),
                { PlayerType.PLAYER_JACOB, PlayerType.PLAYER_JACOB_B, PlayerType.PLAYER_JACOB2_B, Astro.Players.LEAH, Astro.Players.LEAH_B },
                {
                    "#{{ArrowGrayRight}} 소지중인 아이템 1개와 {{Quality3}}/{{Quality4}}등급의 아이템을 하나 소환합니다.",
                    "#{{ArrowGrayRight}} {{Quality3}}/{{Quality4}}등급의 아이템을 {{ColorIsaac}}2{{CR}}개 소환합니다."
                },
                nil, "ko_kr", nil
            )
            
            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.PURE_LOVE),
                { PlayerType.PLAYER_JACOB, PlayerType.PLAYER_JACOB_B, PlayerType.PLAYER_JACOB2_B, Astro.Players.LEAH, Astro.Players.LEAH_B },
                "행운 감소 페널티 미적용",
                nil, "ko_kr", nil
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)

        if not isContinued then
            Astro.Data.PureLove = {
                luck = 0
            }
        end
    end
)

---@param player EntityPlayer
local function IsSynergy(player)
    local type= player:GetPlayerType()
    
    return type == PlayerType.PLAYER_JACOB or type == PlayerType.PLAYER_JACOB_B or type == PlayerType.PLAYER_JACOB2_B or Astro:IsLeah(player)
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == Astro.Collectible.PURE_LOVE then
                    -- if player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                    --     player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    --     player:SetActiveCharge(100, j)
                    --     player:RemoveCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    -- else
                        player:SetActiveCharge(50, j)
                    -- end

                    if Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE1_1 then
                        Astro:DisplayRoom(RoomType.ROOM_SUPERSECRET)
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
        if Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE1_1 then
            Astro:DisplayRoom(RoomType.ROOM_SUPERSECRET)
        end
    end,
    Astro.Collectible.PURE_LOVE
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        if Game():GetLevel():GetCurrentRoom():GetType() ~= RoomType.ROOM_SUPERSECRET then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local targetCollectables = {}

        for _, config in ipairs(Astro.CollectableConfigs) do
            if config.Quality >= 3 and config:IsAvailable() and not config.Hidden then
                table.insert(targetCollectables, config.ID)
            end
        end

        local rng = playerWhoUsedItem:GetCollectibleRNG(Astro.Collectible.PURE_LOVE)

        
        if IsSynergy(playerWhoUsedItem) then
            local hadCollectables = Astro:GetRandomCollectibles(targetCollectables, rng, 2, Astro.Collectible.PURE_LOVE, true)
            
            for _, hadCollectable in ipairs(hadCollectables) do
                Astro:SpawnCollectible(hadCollectable, playerWhoUsedItem.Position, Astro.Collectible.PURE_LOVE)
            end
        else
            local hadCollectable = Astro:GetRandomCollectibles(Astro:getPlayerInventory(playerWhoUsedItem, false), rng, 1, Astro.Collectible.PURE_LOVE, true)[1]
            local newCollectable = Astro:GetRandomCollectibles(targetCollectables, rng, 1, nil, true)[1]
    
            if hadCollectable then
                Astro:SpawnCollectible(hadCollectable, playerWhoUsedItem.Position, Astro.Collectible.PURE_LOVE)
                playerWhoUsedItem:RemoveCollectible(hadCollectable)
            end
    
            if newCollectable then
                Astro:SpawnCollectible(newCollectable, playerWhoUsedItem.Position, Astro.Collectible.PURE_LOVE)
            end

            Astro.Data.PureLove.luck = Astro.Data.PureLove.luck - 1
            
            playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_LUCK)
            playerWhoUsedItem:EvaluateItems()
        end

        SFXManager():Play(useSound, useSoundVolume)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.PURE_LOVE
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if not IsSynergy(player) and Astro.Data.PureLove ~= nil then
            player.Luck = player.Luck + Astro.Data.PureLove.luck
        end
    end,
    CacheFlag.CACHE_LUCK
)

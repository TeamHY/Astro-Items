local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.PURE_LOVE = Isaac.GetItemIdByName("Pure Love")

local useSound = Isaac.GetSoundIdByName('Destroyed')
local useSoundVolume = 1 -- 0 ~ 1

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.PURE_LOVE,
                "순애",
                "...",
                "일급 비밀방에서 사용 시 {{LuckSmall}}행운이 1 감소하고 소지한 아이템 1개와 {{Quality3}}3등급/{{Quality4}}4등급 아이템 1개를 소환합니다. 하나를 선택하면 나머지는 사라집니다." ..
                "#야곱, 알트 야곱, 레아, 라헬이 아닐 경우 사용 시 행운이 감소되지 않습니다." ..
                "#1 스테이지일 경우 맵에 {{SuperSecretRoom}}일급 비밀방 위치가 표시됩니다." ..
                "#스테이지 진입 시 쿨타임이 채워집니다."
            )
        end

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
        Astro:DisplayRoom(RoomType.ROOM_SUPERSECRET)
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
            if config.Quality >= 3 then
                table.insert(targetCollectables, config.ID)
            end
        end

        local rng = playerWhoUsedItem:GetCollectibleRNG(Astro.Collectible.PURE_LOVE)
        local hadCollectable = Astro:GetRandomCollectibles(Astro:getPlayerInventory(playerWhoUsedItem, false), rng, 1, Astro.Collectible.PURE_LOVE, true)[1]
        local newCollectable = Astro:GetRandomCollectibles(targetCollectables, rng, 1, nil, true)[1]

        if hadCollectable then
            Astro:SpawnCollectible(hadCollectable, playerWhoUsedItem.Position, Astro.Collectible.PURE_LOVE)
            playerWhoUsedItem:RemoveCollectible(hadCollectable)
        end

        if newCollectable then
            Astro:SpawnCollectible(newCollectable, playerWhoUsedItem.Position, Astro.Collectible.PURE_LOVE)
        end

        SFXManager():Play(useSound, useSoundVolume)

        if not IsSynergy(playerWhoUsedItem) then
            Astro.Data.PureLove.luck = Astro.Data.PureLove.luck - 1

            playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_LUCK)
            playerWhoUsedItem:EvaluateItems()
        end

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

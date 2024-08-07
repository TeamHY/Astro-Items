AstroItems.Collectible.PURE_LOVE = Isaac.GetItemIdByName("Pure Love")

local useSound = Isaac.GetSoundIdByName('Destroyed')
local useSoundVoulme = 1 -- 0 ~ 1

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if EID then
            AstroItems:AddEIDCollectible(
                AstroItems.Collectible.PURE_LOVE,
                "순애",
                "...",
                "일급 비밀방에서 사용 시 {{LuckSmall}}행운이 1 감소하고 대결 모드에서 현재 판 금지된 아이템 중 하나를 소환합니다.#야곱, 알트 야곱, 레아, 라헬이 아닐 경우 사용 시 행운이 감소되지 않고 소환되는 아이템이 2개로 증가합니다. 하나를 선택하면 나머지는 사라집니다.#스테이지 진입 시 쿨타임이 채워집니다."
            )
        end

        if not isContinued then
            AstroItems.Data.PureLove = {
                luck = 0
            }
        end
    end
)

---@param player EntityPlayer
local function IsSynergy(player)
    local type= player:GetPlayerType()
    
    return type == PlayerType.PLAYER_JACOB or type == PlayerType.PLAYER_JACOB_B or type == PlayerType.PLAYER_JACOB2_B or AstroItems:IsLeah(player)
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == AstroItems.Collectible.PURE_LOVE then
                    -- if player:GetPlayerType() == AstroItems.Players.WATER_ENCHANTRESS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                    --     player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    --     player:SetActiveCharge(100, j)
                    --     player:RemoveCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    -- else
                        player:SetActiveCharge(50, j)
                    -- end
                end
            end
        end
    end
)


AstroItems:AddCallback(
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

        if not Astro or not Astro.Data or not Astro.Data.currentBanItems then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local rng = playerWhoUsedItem:GetCollectibleRNG(AstroItems.Collectible.PURE_LOVE)

        local hadCollectables = {}

        if IsSynergy(playerWhoUsedItem) then
            hadCollectables = AstroItems:GetRandomCollectibles(Astro.Data.currentBanItems, rng, 2)
        else
            hadCollectables = AstroItems:GetRandomCollectibles(Astro.Data.currentBanItems, rng, 1)
        end

        if hadCollectables[1] == nil then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        for _, hadCollectable in ipairs(hadCollectables) do
            AstroItems:SpawnCollectible(hadCollectable, playerWhoUsedItem.Position, AstroItems.Collectible.PURE_LOVE)
            playerWhoUsedItem:RemoveCollectible(hadCollectable)
        end

        SFXManager():Play(useSound, useSoundVoulme)

        if not IsSynergy(playerWhoUsedItem) then
            AstroItems.Data.PureLove.luck = AstroItems.Data.PureLove.luck - 1

            playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_LUCK)
            playerWhoUsedItem:EvaluateItems()
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.PURE_LOVE
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if not IsSynergy(player) and AstroItems.Data.PureLove ~= nil then
            player.Luck = player.Luck + AstroItems.Data.PureLove.luck
        end
    end,
    CacheFlag.CACHE_LUCK
)

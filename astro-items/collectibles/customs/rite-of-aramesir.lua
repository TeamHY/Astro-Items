AstroItems.Collectible.RITE_OF_ARAMESIR = Isaac.GetItemIdByName("Rite of Aramesir")

local useSound = Isaac.GetSoundIdByName('Specialsummon')
local useSoundVoulme = 1 -- 0 ~ 1

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if EID then
            AstroItems:AddEIDCollectible(AstroItems.Collectible.RITE_OF_ARAMESIR, "아라메시아의 의", "당신은 오랜 맹약의 의식에 의해 이 세계에 내려왔습니다. ", "사용 시 {{Trinket" .. AstroItems.Trinket.BLACK_MIRROR .. "}}Black Mirror를 소환합니다.#스테이지 진입 시 쿨타임이 채워집니다.#성전의 수견사, 일리걸 나이트가 아닐 경우 사용 시 {{SmallLuck}}행운이 2 감소합니다.")
        end

        if not isContinued then
            AstroItems.Data.RiteOfAramesir = {
                luck = 0
            }
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == AstroItems.Collectible.RITE_OF_ARAMESIR then
                    if player:GetPlayerType() == AstroItems.Players.WATER_ENCHANTRESS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                        player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                        player:SetActiveCharge(100, j)
                        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    else
                        player:SetActiveCharge(50, j)
                    end
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
        AstroItems:SpawnTrinket(AstroItems.Trinket.BLACK_MIRROR, playerWhoUsedItem.Position)

        SFXManager():Play(useSound, useSoundVoulme)

        if not AstroItems:IsWaterEnchantress(playerWhoUsedItem) then
            AstroItems.Data.RiteOfAramesir.luck = AstroItems.Data.RiteOfAramesir.luck - 2

            playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_LUCK)
            playerWhoUsedItem:EvaluateItems()
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.RITE_OF_ARAMESIR
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if not AstroItems:IsWaterEnchantress(player) and AstroItems.Data.RiteOfAramesir ~= nil then
            player.Luck = player.Luck + AstroItems.Data.RiteOfAramesir.luck
        end
    end,
    CacheFlag.CACHE_LUCK
)


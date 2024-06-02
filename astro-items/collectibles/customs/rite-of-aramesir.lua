AstroItems.Collectible.RITE_OF_ARAMESIR = Isaac.GetItemIdByName("Rite of Aramesir")

local useSound = Isaac.GetSoundIdByName('Specialsummon')
local useSoundVoulme = 1 -- 0 ~ 1

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if EID then
            AstroItems:AddEIDCollectible(AstroItems.Collectible.RITE_OF_ARAMESIR, "아라메시아의 의", "당신은 오랜 맹약의 의식에 의해 이 세계에 내려왔습니다. ", "사용 시 {{Trinket" .. AstroItems.Trinket.BLACK_MIRROR .. "}}Black Mirror를 소환합니다.#스테이지 진입 시 쿨타임이 채워집니다.")
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

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.RITE_OF_ARAMESIR
)

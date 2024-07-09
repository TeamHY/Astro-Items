AstroItems.Collectible.BONFIRE = Isaac.GetItemIdByName("Bonfire")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.BONFIRE,
        "화톳불",
        "...",
        "사용 시 화염 관련 아이템 1개가 소환됩니다. 디아벨스타일 경우 2개 소환됩니다. 하나를 선택하면 나머지는 사라집니다.#!!! 일회용 아이템"
    )
end

--- @type CollectibleType[]
local fireItems = {}

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        fireItems = {
            CollectibleType.COLLECTIBLE_CANDLE,
            CollectibleType.COLLECTIBLE_RED_CANDLE
        }
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
        local items = AstroItems:GetRandomCollectibles(fireItems, rngObj, 2)
        
        if playerWhoUsedItem:GetPlayerType() == AstroItems.Players.DIABELLSTAR then
            local optionsPickupIndex = AstroItems.Collectible.BONFIRE * 10000

            AstroItems:SpawnCollectible(items[1], playerWhoUsedItem.Position, optionsPickupIndex)
            AstroItems:SpawnCollectible(items[2], playerWhoUsedItem.Position, optionsPickupIndex)
        else
            AstroItems:SpawnCollectible(items[1], playerWhoUsedItem.Position)
        end

        SFXManager():Play(SoundEffect.SOUND_FIREDEATH_HISS)

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.BONFIRE
)

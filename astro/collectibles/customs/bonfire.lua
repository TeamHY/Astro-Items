Astro.Collectible.BONFIRE = Isaac.GetItemIdByName("Bonfire")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BONFIRE,
        "화톳불",
        "화르륵",
        "!!! 일회용" ..
        "#{{Burning}} 사용 시 {{Collectible164}}The Candle/{{Collectible289}}Red Candle 중 하나를 소환합니다." ..
        "#캐릭터가 Diabellstar이거나 둘 다 소환될 경우 하나를 선택하면 나머지는 사라집니다."
    )
end

--- @type CollectibleType[]
local fireItems = {}

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        fireItems = {
            CollectibleType.COLLECTIBLE_CANDLE,
            CollectibleType.COLLECTIBLE_RED_CANDLE
        }
    end
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
        local items = Astro:GetRandomCollectibles(fireItems, rngObj, 2)
        
        if playerWhoUsedItem:GetPlayerType() == Astro.Players.DIABELLSTAR then
            local optionsPickupIndex = Astro.Collectible.BONFIRE * 10000

            Astro:SpawnCollectible(items[1], playerWhoUsedItem.Position, optionsPickupIndex)
            Astro:SpawnCollectible(items[2], playerWhoUsedItem.Position, optionsPickupIndex)
        else
            Astro:SpawnCollectible(items[1], playerWhoUsedItem.Position)
        end

        SFXManager():Play(SoundEffect.SOUND_FIREDEATH_HISS)

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.BONFIRE
)

Astro.Collectible.ALMAGEST = Isaac.GetItemIdByName("Almagest")

local ITEM_ID = Astro.Collectible.ALMAGEST

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "알마게스트",
                "",
                "사용 시 그 방의 아이템을 {{Collectible" .. Astro.Collectible.PTOLEMAEUS .. "}}Ptolemaeus로 변경합니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Almagest", "",
                "Turns items in the room into {{Collectible" .. Astro.Collectible.PTOLEMAEUS .. "}} Ptolemaeus",
                nil, "en_us"
            )
        end
    end
)

---@param pickup EntityPickup
---@return boolean
local function CanChangeToPtolemaeus(pickup)
    if pickup.SubType == CollectibleType.COLLECTIBLE_NULL or pickup.SubType == Astro.Collectible.PTOLEMAEUS then
        return false
    end

    local itemConfigItem = Isaac.GetItemConfig():GetCollectible(pickup.SubType)

    return not (itemConfigItem and itemConfigItem:HasTags(ItemConfig.TAG_QUEST))
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = entity:ToPickup()

            if CanChangeToPtolemaeus(pickup) then
                pickup:Morph(pickup.Type, pickup.Variant, Astro.Collectible.PTOLEMAEUS, true)
                pickup.Touched = false
                Game():SpawnParticles(pickup.Position, EffectVariant.POOF01, 1, 0)
            end
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    ITEM_ID
)

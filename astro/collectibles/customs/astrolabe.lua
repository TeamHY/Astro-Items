Astro.Collectible.ASTROLABE = Isaac.GetItemIdByName("Astrolabe")

local ITEM_ID = Astro.Collectible.ASTROLABE

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "아스트롤라베",
                "모든 길은 별을 향한다",
                "사용 시 그 방의 아이템을 {{Planetarium}}천체관 아이템으로 변경합니다." ..
                "#방에 아이템이 없으면 {{Planetarium}}천체관 아이템을 1개 소환하고 사라집니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Astrolabe", "",
                "Rerolls items in the room into {{Planetarium}} planetarium items" ..
                "#If there are no items in the room, spawns 1 {{Planetarium}} planetarium item and disappears",
                nil, "en_us"
            )
        end
    end
)

---@param pickup EntityPickup
---@return boolean
local function CanChange(pickup)
    if pickup.SubType == CollectibleType.COLLECTIBLE_NULL then
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
        local itemPool = Game():GetItemPool()
        local hasItem = false

        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = entity:ToPickup()

            if CanChange(pickup) then
                hasItem = true
                pickup:Morph(pickup.Type, pickup.Variant, itemPool:GetCollectible(ItemPoolType.POOL_PLANETARIUM, true, rngObj:Next()), true)
                pickup.Touched = false
                Game():SpawnParticles(pickup.Position, EffectVariant.POOF01, 1, 0)
            end
        end

        if not hasItem then
            Astro:SpawnCollectible(itemPool:GetCollectible(ItemPoolType.POOL_PLANETARIUM, true, rngObj:Next()), playerWhoUsedItem.Position)
        end

        return {
            Discharge = true,
            Remove = not hasItem,
            ShowAnim = true,
        }
    end,
    ITEM_ID
)

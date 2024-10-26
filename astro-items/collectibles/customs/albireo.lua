---

local ALL_STAT_MULTIPLIER = 1.1

---

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.ALBIREO = Isaac.GetItemIdByName("Albireo")

local function Init()
    if EID then
        AstroItems:AddEIDCollectible(
            AstroItems.Collectible.ALBIREO,
            "알비레오",
            "...",
            "사용 시 방에 있는 별자리, 행성 아이템이 강화됩니다." ..
            "#{{Collectible" .. AstroItems.Collectible.CYGNUS .. "}}Cygnus 소지 시 올스탯이 x1.1 증가합니다." ..
            "#!!! 일회용 아이템 (스텔라 제외)"
        )
    end
end

AstroItems:AddCallback(
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
            local id = pickup.SubType

            if AstroItems.UPGRADE_LIST[id] then
                pickup:Morph(pickup.Type, pickup.Variant, AstroItems.UPGRADE_LIST[id], true)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, pickup.Position, pickup.Velocity, playerWhoUsedItem)
            end
        end

        if playerWhoUsedItem:GetPlayerType() == AstroItems.Players.STELLAR then
            return {
                Discharge = true,
                Remove = false,
                ShowAnim = true,
            }
        end

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.ALBIREO
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:HasCollectible(AstroItems.Collectible.ALBIREO) then
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        end
    end,
    AstroItems.Collectible.CYGNUS
)

AstroItems:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@diagnostic disable-next-line: param-type-mismatch
    CallbackPriority.LATE + 2000, -- 혼줌과 동일
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function (_, player, cacheFlag)
        if not player:HasCollectible(AstroItems.Collectible.ALBIREO) or not player:HasCollectible(AstroItems.Collectible.CYGNUS) then return end

        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = ((player.MaxFireDelay + 1) / ALL_STAT_MULTIPLIER) - 1
        end

        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_LUCK and player.Luck > 0 then
            player.Luck = player.Luck * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed * ALL_STAT_MULTIPLIER
        end
    end
)

return {
    Init = Init
}

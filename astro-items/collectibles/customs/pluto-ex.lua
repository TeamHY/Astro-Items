local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.PLUTO_EX = Isaac.GetItemIdByName("PLUTO EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.PLUTO_EX,
        "초 명왕성",
        "...",
        "{{Collectible597}}Pluto 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#(미완성)방 입장 시 모든 적이 작아집니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.PLUTO_EX) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_GODS_FLESH
        end
    end,
    CacheFlag.CACHE_TEARFLAG
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_PLUTO)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_PLUTO) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_PLUTO)
        end
    end,
    AstroItems.Collectible.PLUTO_EX
)

-- AstroItems:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_PLUTO) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_PLUTO)
--         end
--     end,
--     AstroItems.Collectible.PLUTO_EX
-- )

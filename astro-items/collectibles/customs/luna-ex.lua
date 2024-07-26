local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.LUNA_EX = Isaac.GetItemIdByName("LUNA EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.LUNA_EX,
        "초 달",
        "...",
        EID:getDescriptionObj(5, 100, CollectibleType.COLLECTIBLE_LUNA, nil, false).Description ..
        "#" .. EID:getDescriptionObj(5, 100, CollectibleType.COLLECTIBLE_XRAY_VISION, nil, false).Description ..
        "#" .. EID:getDescriptionObj(5, 100, CollectibleType.COLLECTIBLE_BLUE_MAP, nil, false).Description ..
        "#행운을 항상 가장 높았던 값으로 고정합니다."
    )
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_LUNA) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_LUNA)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_XRAY_VISION)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_BLUE_MAP)
            hiddenItemManager:Add(player, AstroItems.Collectible.LUCKY_ROCK_BOTTOM)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    AstroItems.Collectible.LUNA_EX
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_LUNA) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_LUNA)
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_XRAY_VISION)
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_BLUE_MAP)
            hiddenItemManager:Remove(player, AstroItems.Collectible.LUCKY_ROCK_BOTTOM)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    AstroItems.Collectible.LUNA_EX
)

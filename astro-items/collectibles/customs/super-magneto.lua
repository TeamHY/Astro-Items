local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.SUPER_MAGNETO = Isaac.GetItemIdByName("Super Magneto")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.SUPER_MAGNETO, "슈퍼 마그넷", "...", "Quickpick 모드의 사거리가 무한으로 변경됩니다.")
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not QP_OVERWRITE then
            QP_OVERWRITE = {}
        end

        QP_OVERWRITE.isInfinity = true
    end,
    AstroItems.Collectible.SUPER_MAGNETO
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if QP_OVERWRITE then
            QP_OVERWRITE.isInfinity = false
        end
    end,
    AstroItems.Collectible.SUPER_MAGNETO
)

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.SUPER_MAGNETO = Isaac.GetItemIdByName("Super Magneto")

if EID then
    Astro.EID:AddCollectible(Astro.Collectible.SUPER_MAGNETO, "슈퍼 마그넷", "당기시오", "Quickpick 모드의 사거리가 무한으로 변경됩니다.")
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not QP_OVERWRITE then
            QP_OVERWRITE = {}
        end

        QP_OVERWRITE.isInfinity = true
    end,
    Astro.Collectible.SUPER_MAGNETO
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if QP_OVERWRITE then
            QP_OVERWRITE.isInfinity = false
        end
    end,
    Astro.Collectible.SUPER_MAGNETO
)

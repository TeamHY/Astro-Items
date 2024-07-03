local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.ABSOLUT_CONJOINED = Isaac.GetItemIdByName("Absolut Conjoined")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.ABSOLUT_CONJOINED,
        "앱솔루트 종양",
        "...",
        "!!! 처음 획득 시 3개를 획득합니다."
    )
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.ABSOLUT_CONJOINED) then
            player:AddCollectible(AstroItems.Collectible.ABSOLUT_CONJOINED)
            player:AddCollectible(AstroItems.Collectible.ABSOLUT_CONJOINED)
        end
    end,
    AstroItems.Collectible.ABSOLUT_CONJOINED
)

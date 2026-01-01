local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.ABSOLUT_CONJOINED = Isaac.GetItemIdByName("Absolut Conjoined")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.ABSOLUT_CONJOINED,
        "완전한 샴쌍둥이",
        "종양!",
        "Conjoined 세트가 적용됩니다."
    )
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.ABSOLUT_CONJOINED) then
            player:AddCollectible(Astro.Collectible.ABSOLUT_CONJOINED)
            player:AddCollectible(Astro.Collectible.ABSOLUT_CONJOINED)
        end
    end,
    Astro.Collectible.ABSOLUT_CONJOINED
)

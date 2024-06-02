local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.GO_HOME = Isaac.GetItemIdByName("Go Home!")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.GO_HOME, "집으로!", "...", "!!! 획득 시 사라지고 Home으로 이동합니다.")
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Isaac.ExecuteCommand("stage 13")

        player:RemoveCollectible(AstroItems.Collectible.GO_HOME)
    end,
    AstroItems.Collectible.GO_HOME
)

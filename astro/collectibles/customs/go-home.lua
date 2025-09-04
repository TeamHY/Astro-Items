local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.GO_HOME = Isaac.GetItemIdByName("Go Home!")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.GO_HOME,
        "집으로!",
        "> stage 13",
        "!!! 획득 시 Home 스테이지로 이동"
    )
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Isaac.ExecuteCommand("stage 13")

        player:RemoveCollectible(Astro.Collectible.GO_HOME)
    end,
    Astro.Collectible.GO_HOME
)

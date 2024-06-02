local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.REINCARNATION = Isaac.GetItemIdByName("Reincarnation")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.REINCARNATION, "리인카네이션", "...", "다음 게임 시작 시 {{Collectible482}}Clicker가 소환됩니다.")
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.RunReincarnation then
            local player = Isaac.GetPlayer()

            AstroItems:SpawnCollectible(CollectibleType.COLLECTIBLE_CLICKER, player.Position)

            AstroItems.Data.RunReincarnation = false
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        AstroItems.Data.RunReincarnation = true
    end,
    AstroItems.Collectible.REINCARNATION
)

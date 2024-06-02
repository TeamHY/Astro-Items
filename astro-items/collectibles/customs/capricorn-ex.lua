local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.CAPRICORN_EX = Isaac.GetItemIdByName("Capricorn EX")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.CAPRICORN_EX, "초 염소자리", "...", "획득 시 {{Trinket174}}Number Magnet, {{Pill1}}Gulp!가 소환됩니다")
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.CAPRICORN_EX) then
            AstroItems:SpawnPill(PillEffect.PILLEFFECT_GULP, player.Position)
            AstroItems:SpawnTrinket(TrinketType.TRINKET_NUMBER_MAGNET, player.Position)
        end
    end,
    AstroItems.Collectible.CAPRICORN_EX
)


local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.CASIOPEA = Isaac.GetItemIdByName("Casiopea")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.CASIOPEA, "카시오페아", "...", "#획득 시 랜덤 황금 장신구와 {{Pill1}}Gulp!가 소환됩니다.#다음 게임 시작 시 랜덤 황금 장신구가 소환됩니다.#중첩이 가능합니다.")
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.CasiopeaCount ~= nil and AstroItems.Data.CasiopeaCount > 0 then
            local itemPool = Game():GetItemPool()

            for _ = 1, AstroItems.Data.CasiopeaCount do
                AstroItems:SpawnTrinket(itemPool:GetTrinket() + 32768, Game():GetRoom():GetCenterPos())
            end

            AstroItems.Data.CasiopeaCount = 0
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.CASIOPEA) then
            local game = Game()
            local itemPool = game:GetItemPool()

            AstroItems:SpawnPill(PillEffect.PILLEFFECT_GULP, player.Position)
            AstroItems:SpawnTrinket(itemPool:GetTrinket() + 32768, player.Position)
        end

        AstroItems.Data.CasiopeaCount = player:GetCollectibleNum(AstroItems.Collectible.CASIOPEA)
    end,
    AstroItems.Collectible.CASIOPEA
)

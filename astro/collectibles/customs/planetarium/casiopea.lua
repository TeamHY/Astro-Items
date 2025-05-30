local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.CASIOPEA = Isaac.GetItemIdByName("Casiopea")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.CASIOPEA, "카시오페아", "...", "#획득 시 무작위 황금 장신구와 {{Pill1}}Gulp!를 소환합니다.#다음 게임에서 무작위 황금 장신구를 소환합니다.#중첩이 가능합니다.")
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.CasiopeaCount ~= nil and Astro.Data.CasiopeaCount > 0 then
            local itemPool = Game():GetItemPool()

            for _ = 1, Astro.Data.CasiopeaCount do
                Astro:SpawnTrinket(itemPool:GetTrinket() + 32768, Game():GetRoom():GetCenterPos())
            end

            Astro.Data.CasiopeaCount = 0
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.CASIOPEA) then
            local game = Game()
            local itemPool = game:GetItemPool()

            Astro:SpawnPill(PillEffect.PILLEFFECT_GULP, player.Position)
            Astro:SpawnTrinket(itemPool:GetTrinket() + 32768, player.Position)
        end

        Astro.Data.CasiopeaCount = player:GetCollectibleNum(Astro.Collectible.CASIOPEA)
    end,
    Astro.Collectible.CASIOPEA
)

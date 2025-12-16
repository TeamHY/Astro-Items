---

Astro.Trinket.OBSIDIAN_HAND = Isaac.GetTrinketIdByName("Obsidian Hand")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDTrinket(
                Astro.Trinket.OBSIDIAN_HAND,
                "흑요석 손",
                "날카로운 꿈",
                "{{Trinket}} 스테이지 진입 시 소지중인 장신구를 흡수해 효과를 영구적으로 얻습니다."
            )

            Astro:AddEIDTrinket(
                Astro.Trinket.OBSIDIAN_HAND,
                "Obsidian Hand",
                "",
                "{{Trinket}} Consumes the Isaac's trinket at every new floor and grants its effect as a permanent passive effect",
                nil, "en_us"
            )

        -- Astro:AddGoldenTrinketDescription(Astro.Trinket.OBSIDIAN_HAND, "", 10)
        end
    end
)

---@param player EntityPlayer
function Astro:ActivateObsidianHandEffect(player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM)
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Game():GetPlayer(i)
            
            if player:HasTrinket(Astro.Trinket.OBSIDIAN_HAND) then
                Astro:ActivateObsidianHandEffect(player)
            end
        end
    end
)

---

Astro.Trinket.OBSIDIAN_HAND = Isaac.GetTrinketIdByName("Obsidian Hand")

if EID then
    Astro:AddEIDTrinket(
        Astro.Trinket.OBSIDIAN_HAND,
        "스테이지 입장 시 {{Collectible479}}Smelter 1회를 발동합니다.",
        "옵시디언 손", "..."
    )

-- Astro:AddGoldenTrinketDescription(Astro.Trinket.OBSIDIAN_HAND, "", 10)
end

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

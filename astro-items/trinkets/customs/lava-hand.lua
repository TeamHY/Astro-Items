local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Trinket.LAVA_HAND = Isaac.GetTrinketIdByName("Lava Hand")

if EID then
    EID:addTrinket(
        AstroItems.Trinket.LAVA_HAND,
        "{{Trinket145}}Perfection을 제외한 장신구를 획득 시 즉시 흡수됩니다.",
        "용암 손"
    )

    -- Astro:AddGoldenTrinketDescription(Astro.Trinket.LAVA_HAND, "", 10)
end

---@param player EntityPlayer
---@param trinket TrinketType
function AstroItems:UpdateLavaHandEffect(player, trinket)
    if player:HasTrinket(AstroItems.Trinket.LAVA_HAND) and not AstroItems:CheckTrinket(trinket, TrinketType.TRINKET_PERFECTION) then
        isc:smeltTrinket(player, trinket)
        player:TryRemoveTrinket(trinket)
    end
end

local isc = require("astro.lib.isaacscript-common")

Astro.Trinket.LAVA_HAND = Isaac.GetTrinketIdByName("Lava Hand")

if EID then
    EID:addTrinket(Astro.Trinket.LAVA_HAND, "{{Collectible479}} 장신구 획득 시 즉시 흡수됩니다. ({{Trinket145}}Perfection 제외)", "용암 손")

-- Astro:AddGoldenTrinketDescription(Astro.Trinket.LAVA_HAND, "", 10)
end

---@param player EntityPlayer
---@param trinket TrinketType
function Astro:UpdateLavaHandEffect(player, trinket)
    if not Astro:CheckTrinket(trinket, TrinketType.TRINKET_PERFECTION) and not Astro:CheckTrinket(trinket, Astro.Trinket.FLUNK) then
        isc:smeltTrinket(player, trinket)
        player:TryRemoveTrinket(trinket)
    end
end

Astro:AddPriorityCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    CallbackPriority.LATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasTrinket(Astro.Trinket.LAVA_HAND) then
            for i = 0, 1 do -- TrinketIndex 0 ~ 1
                local trinket = player:GetTrinket(i)

                if trinket == TrinketType.TRINKET_NULL then
                    break
                end

                Astro:UpdateLavaHandEffect(player, trinket)
            end
        end
    end
)

---

local COIN_CONSUMPTION = 5

---

Astro.Trinket.LAVA_HAND = Isaac.GetTrinketIdByName("Lava Hand")

if EID then
    Astro:AddEIDTrinket(
        Astro.Trinket.LAVA_HAND,
        "{{Collectible479}} 장신구 소지 시 5원을 소모하고 흡수합니다.",
        "용암 손", "..."
    )

-- Astro:AddGoldenTrinketDescription(Astro.Trinket.LAVA_HAND, "", 10)
end

---@param player EntityPlayer
function Astro:UpdateLavaHandEffect(player)
    if player:GetNumCoins() < COIN_CONSUMPTION then
        return
    end

    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM)
    player:AddCoins(-COIN_CONSUMPTION)
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

                Astro:UpdateLavaHandEffect(player)
            end
        end
    end
)

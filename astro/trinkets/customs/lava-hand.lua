---

local COIN_CONSUMPTION = 5

---

Astro.Trinket.LAVA_HAND = Isaac.GetTrinketIdByName("Lava Hand")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDTrinket(
                Astro.Trinket.LAVA_HAND,
                "용암 손",
                "녹아내려",
                "{{Trinket}} 획득 이후 장신구를 획득한 즉시 동전 5원을 소모하고 해당 장신구를 흡수해 효과를 영구적으로 얻습니다."
            )

            Astro:AddEIDTrinket(
                Astro.Trinket.LAVA_HAND,
                "Lava Hand",
                "",
                "{{Trinket}} Consumes Isaac's held trinkets by spending 5 coins upon pickup and grants their effects permanently",
                nil, "en_us"
            )

        -- Astro:AddGoldenTrinketDescription(Astro.Trinket.LAVA_HAND, "", 10)
        end
    end
)

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

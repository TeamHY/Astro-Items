local isc = require("astro.lib.isaacscript-common")

Astro.Trinket.ELECTRONIC_PENNY = Isaac.GetTrinketIdByName("Electronic Penny")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddTrinket(
                Astro.Trinket.ELECTRONIC_PENNY,
                "전자 동전",
                "에너지 부자",
                "{{Crafting18}} 동전 획득 시 5% 확률로 마이크로 배터리를 드랍합니다." ..
                "#{{LuckSmall}} 행운 95 이상일 때 100% 확률 (행운 1당 +1%p)"
            )

            Astro.EID:AddTrinket(
                Astro.Trinket.ELECTRONIC_PENNY,
                "Electronic Penny",
                "",
                "{{Crafting18}} Picking up a coin has a 5% chance to spawn a Micro battery" ..
                "#{{LuckSmall}} 100% chance to at 95 Luck (+1%p per Luck)",
                nil, "en_us"
            )

            Astro:AddGoldenTrinketDescription(Astro.Trinket.ELECTRONIC_PENNY, "", 5, 2)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PICKUP_COLLECT,
    ---@param pickup EntityPickup
    ---@param player EntityPlayer
    function(_, pickup, player)
        if pickup.Variant == PickupVariant.PICKUP_COIN then
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            if player:HasTrinket(Astro.Trinket.ELECTRONIC_PENNY) then
                local rng = player:GetTrinketRNG(Astro.Trinket.ELECTRONIC_PENNY)

                if rng:RandomFloat() < 0.05 * player:GetTrinketMultiplier(Astro.Trinket.ELECTRONIC_PENNY) + player.Luck / 100 then
                    Isaac.Spawn(
                        EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_LIL_BATTERY,
                        2,
                        currentRoom:FindFreePickupSpawnPosition(player.Position, 40, true),
                        Vector.Zero,
                        player
                    )
                end
            end
        end
    end
)

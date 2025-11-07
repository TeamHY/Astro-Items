Astro.Trinket.STOMACH_MEDICINE = Isaac.GetTrinketIdByName("Stomach Medicine")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDTrinket(
                Astro.Trinket.STOMACH_MEDICINE,
                "위장약",
                "상상으로 만든 복통",
                "{{Pill}} 알약 사용 시 {{Collectible35}} 그 방의 적에게 40의 방어 무시 피해를 줍니다."
            )

            Astro:AddGoldenTrinketDescription(Astro.Trinket.STOMACH_MEDICINE, "", 40, 2)
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_USE_PILL,
    ---@param pillEffect PillEffect
    ---@param player EntityPlayer
    ---@param flag UseFlags
    function(_, pillEffect, player, flag)
        if flag >= 2048 then return end    -- 에코 챔버

        if player:HasTrinket(Astro.Trinket.STOMACH_MEDICINE) then
            for i = 1, player:GetTrinketMultiplier(Astro.Trinket.STOMACH_MEDICINE) do
                player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, false)
            end
        end
    end
)
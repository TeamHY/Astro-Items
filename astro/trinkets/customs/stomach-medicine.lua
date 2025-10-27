Astro.Trinket.STOMACH_MEDICINE = Isaac.GetTrinketIdByName("Stomach Medicine")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDTrinket(
                Astro.Trinket.STOMACH_MEDICINE,
                "위장약",
                "상상으로 만든 복통",
                "{{Collectible35}} {{Pill}}알약을 사용할 때마다 그 방의 적에게 40의 방어 무시 피해를 줍니다."
            )
        end
    end
)


-- 에코 챔버 테스트안해봄
Astro:AddCallback(
    ModCallbacks.MC_USE_PILL,
    ---@param pillEffect PillEffect
    ---@param player EntityPlayer
    ---@param flag UseFlags
    function(_, pillEffect, player, flag)
        if player:HasTrinket(Astro.Trinket.STOMACH_MEDICINE) then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, false)
        end
    end
)
---

local PENALTY_TIME = 2 * 10 * 30 -- 가운데가 패널티 시간

---

Astro.Collectible.CYGNUS = Isaac.GetItemIdByName("Cygnus")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            -- 15초 -> 7.5초 -> 5초
            Astro:AddEIDCollectible(
                Astro.Collectible.CYGNUS,
                "백조자리",
                "백조같이 도망가던 신",
                "15초마다 빛줄기가 2번 떨어집니다." ..
                "#!!! 페널티 피격 시 20초동안 효과가 중지됩니다.",
                -- 중첩 시
                "빛줄기 소환 쿨타임 감소"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.CYGNUS) then
            local frameCount = Game():GetFrameCount()

            if frameCount % math.floor(450 / player:GetCollectibleNum(Astro.Collectible.CYGNUS)) == 0 and Astro:GetLastPenaltyFrame(player) + PENALTY_TIME < frameCount then
                player:UseActiveItem(160, false, true, false, false)
                player:UseActiveItem(160, false, true, false, false)
            end
        end
    end
)

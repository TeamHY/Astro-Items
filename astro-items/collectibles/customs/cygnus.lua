AstroItems.Collectible.CYGNUS = Isaac.GetItemIdByName("Cygnus")

if EID then
    -- 15초 -> 7.5초 -> 5초
    AstroItems:AddEIDCollectible(AstroItems.Collectible.CYGNUS, "백조자리", "...", "게임 시간 15초마다 2번 빛줄기를 소환합니다.#중첩 시 발동 간격이 줄어듭니다.")
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(AstroItems.Collectible.CYGNUS) then
            if Game():GetFrameCount() % math.floor(450 / player:GetCollectibleNum(AstroItems.Collectible.CYGNUS)) == 0 then
                player:UseActiveItem(160, false, true, false, false)
                player:UseActiveItem(160, false, true, false, false)
            end
        end
    end
)

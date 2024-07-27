---

-- 대각선 스피드 증가량
-- 0 -> 스피드가 증가하지 않음
-- 0.5 -> 스피드가 1.5배 증가
-- 1 -> 스피드가 2배 증가
-- 1.5 -> 스피드가 2.5배 증가
-- 2 -> 스피드가 3배 증가
local MULTIPLIER = 1

---

AstroItems.Collectible.BUNNY_HOP = Isaac.GetItemIdByName("Bunny Hop")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.BUNNY_HOP,
        "토끼뜀",
        "...",
        "대각선으로 이동 시 이동 속도가 증가합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(AstroItems.Collectible.BUNNY_HOP) then
            local angle = math.abs(player.Velocity:Normalized():GetAngleDegrees())
            local diagonalValue = 1 - math.abs(((angle % 90) / 45) - 1)

            local data = player:GetData()

            data.bunnyHopMultiplier = 1 + diagonalValue * MULTIPLIER

            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.BUNNY_HOP) then
            local data = player:GetData()

            if data.bunnyHopMultiplier then
                player.MoveSpeed = player.MoveSpeed * data.bunnyHopMultiplier
            end
        end
    end,
    CacheFlag.CACHE_SPEED
)

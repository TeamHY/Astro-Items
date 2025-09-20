Astro.Collectible.ARIES_EX = Isaac.GetItemIdByName("Aries EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.ARIES_EX,
        "초 양자리",
        "순수함에 보호받다",
        "패널티 피격 시 피해를 무시하고 일시적으로 무적이 됩니다." ..
        "#!!! 지속시간: (10 * {{Collectible" .. Astro.Collectible.ARIES_EX .."}}개수)초" ..
        "#{{TimerSmall}} 쿨타임 60초"
    )
end

--- 쿨타임
local cooldown = 60 * 30

-- --- 지속 시간
-- local duration = 5 * 30

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.ARIES_EX) then
            local data = player:GetData()

            if data.Aries == nil then
                data.Aries = {
                    CooldownTime = 0
                }
            end

            local frameCount = Game():GetFrameCount()

            if data.Aries.CooldownTime <= frameCount then
                data.Aries.CooldownTime = frameCount + cooldown

                for _ = 1, player:GetCollectibleNum(Astro.Collectible.ARIES_EX) do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)
                end

                return false
            end
        end
    end,
    EntityType.ENTITY_PLAYER
)

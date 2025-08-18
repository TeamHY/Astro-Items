Astro.Collectible.ARIES_EX = Isaac.GetItemIdByName("Aries EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.ARIES_EX,
        "초 양자리",
        "일시적 저항",
        "피격 시 그 피격은 무효화되며, 10초간 무적이 됩니다." ..
        "#{{Timer}} 쿨타임 60초"..
        "#{{ArrowGrayRight}} 중첩 시 지속 시간이 증가합니다."
    )
end

--- 쿨타임
local cooldown = 60 * 30

-- --- 지속 시간
-- local duration = 5 * 30

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

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

Astrobirth.Collectible.ARIES_EX = Isaac.GetItemIdByName("Aries EX")

if EID then
    EID:addCollectible(Astrobirth.Collectible.ARIES_EX, "피격 시 무효화 처리되며, 5초간 무적이 됩니다 {{Timer}}쿨타임 25초", "초 양자리")
end

--- 쿨타임
local cooldown = 25 * 30

--- 지속 시간
local duration = 5 * 30

Astrobirth:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player:HasCollectible(Astrobirth.Collectible.ARIES_EX) then
            local data = player:GetData()

            if data.Aries == nil then
                data.Aries = {
                    CooldownTime = 0,
                    DurationTime = 0
                }
            end

            local frameCount = Game():GetFrameCount()

            if data.Aries.CooldownTime <= frameCount then
                data.Aries.CooldownTime = frameCount + cooldown
                data.Aries.DurationTime = frameCount + duration

                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true)

                return false
            end
        end
    end,
    EntityType.ENTITY_PLAYER
)

Astrobirth:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = player:GetData()

            if data.Aries ~= nil then
                if data.Aries.DurationTime <= Game():GetFrameCount() then
                    player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
                end
            end
        end
    end
)
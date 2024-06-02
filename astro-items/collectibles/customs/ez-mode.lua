AstroItems.Collectible.EZ_MODE = Isaac.GetItemIdByName("EZ Mode")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.EZ_MODE, "쉬운 모드", "...", "피격 페널티가 발생하지 않습니다.")
end

-- AstroItems:AddCallback(
--     ModCallbacks.MC_POST_NEW_ROOM,
--     function(_)
--         local level = Game():GetLevel()
--         local currentRoom = level:GetCurrentRoom()

--         if AstroItems:CheckFirstVisitFrame(currentRoom) then
--             if level:GetAbsoluteStage() == LevelStage.STAGE1_1 and level:GetCurrentRoomIndex() == 84 then
--                 AstroItems:SpawnCollectible(AstroItems.Collectible.EZ_MODE, currentRoom:GetGridPosition(33), nil, true)
--             end
--         end
--     end
-- )

AstroItems:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player ~= nil then
            if player:HasCollectible(AstroItems.Collectible.EZ_MODE) then
                if damageFlags & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
                    player:TakeDamage(amount, damageFlags | DamageFlag.DAMAGE_NO_PENALTIES, source, countdownFrames)
                    return false
                end
            end
        end
    end
)

AstroItems.Collectible.VERY_EZ_MODE = Isaac.GetItemIdByName("Very EZ Mode")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.VERY_EZ_MODE, "엄청 쉬운 모드", "...", "후반 스테이지 체력 제한 시스템이 작동하지 않습니다.")
end

-- AstroItems:AddCallback(
--     ModCallbacks.MC_POST_NEW_ROOM,
--     function(_)
--         local level = Game():GetLevel()
--         local currentRoom = level:GetCurrentRoom()

--         if AstroItems:CheckFirstVisitFrame(currentRoom) then
--             if level:GetAbsoluteStage() == LevelStage.STAGE1_1 and level:GetCurrentRoomIndex() == 84 then
--                 AstroItems:SpawnCollectible(AstroItems.Collectible.VERY_EZ_MODE, currentRoom:GetGridPosition(41), nil, true)
--             end
--         end
--     end
-- )

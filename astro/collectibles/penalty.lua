local PENALTY_DEATHS_HEAD_COUNT = 2 -- 빠가지 소환 개수

local PENALTY_DEATHS_HEAD_CHANCE = 1 -- 빠가지 소환 확률

local PENALTY_BROKEN_HEARTS = 3 -- 뼈 심장 추가 개수

-- 패널티 피격 시 차지 감소
local PENALTY_ACTIVE_ITEMS = {
    [CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS] = 2, -- ex) 피격 시 2 감소
}

-- 패널티 피격 시 아이템 제거
local PENALTY_REMOVE_ITEMS = {
    collectible = {
        Astro.Collectible.UNHOLY_MANTLE,
    },
    trinket = {
    }
}

if EID then
    for item, penalty in pairs(PENALTY_ACTIVE_ITEMS) do
        EID:addDescriptionModifier(
            "AstroPenaltyActive" .. item,
            function(descObj)
                if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == item then
                    return true
                end
            end,
            function(descObj)
                EID:appendToDescription(descObj, "#{{ColorRed}}패널티 피격 시 차지가 " .. penalty .. " 감소됩니다.")
                return descObj
            end
        )
    end

    for _, item in ipairs(PENALTY_REMOVE_ITEMS.collectible) do
        EID:addDescriptionModifier(
            "AstroPenaltyRemoveCollectible" .. item,
            function(descObj)
                if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == item then
                    return true
                end
            end,
            function(descObj)
                EID:appendToDescription(descObj, "#{{ColorRed}}패널티 피격 시 제거됩니다.")
                return descObj
            end
        )
    end

    for _, item in ipairs(PENALTY_REMOVE_ITEMS.trinket) do
        EID:addDescriptionModifier(
            "AstroPenaltyRemoveTrinket" .. item,
            function(descObj)
                if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_TRINKET and descObj.ObjSubType == item then
                    return true
                end
            end,
            function(descObj)
                EID:appendToDescription(descObj, "#{{ColorRed}}패널티 피격 시 제거됩니다.")
                return descObj
            end
        )
    end

end

local function CheckBossRoom()
    local level = Game():GetLevel()
    local stage = level:GetAbsoluteStage()
    local currentRoom = level:GetCurrentRoom()
    local currentRoomDesc = Game():GetLevel():GetCurrentRoomDesc()

    if currentRoom:GetType() ~= RoomType.ROOM_BOSS then
        return false
    end

    if currentRoom:IsClear() then
        return false
    end

    if stage == LevelStage.STAGE3_2 and currentRoom:GetBossID() == 6 then
        return true -- 엄마 발
    elseif stage == LevelStage.STAGE4_3 then
        return true -- 허쉬
    elseif stage == LevelStage.STAGE5 then
        return true -- 성당 / 저승
    elseif stage == LevelStage.STAGE6 then
        return true -- 체스트 / 다크룸 / 메가 사탄
    elseif stage == LevelStage.STAGE7 then
        return true -- 델리리움
    elseif currentRoom:GetBossID() == 88 then
        return true -- 마더
    elseif currentRoomDesc.Data.Name == "Beast Room" then
        return true -- 비스트
    end

    return false
end

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        -- 패널티 액티브 아이템 처리
        for item, penalty in pairs(PENALTY_ACTIVE_ITEMS) do
            if player:HasCollectible(item) then
                for i = 0, ActiveSlot.SLOT_POCKET2 do
                    if player:GetActiveItem(i) == item then
                        local charge = player:GetActiveCharge(i)

                        if charge > 0 then
                            player:SetActiveCharge(math.max(0, charge - penalty), i)
                        end
                    end
                end
            end
        end

        for _, item in ipairs(PENALTY_REMOVE_ITEMS.collectible) do
            if player:HasCollectible(item) then
                Astro:RemoveAllCollectible(player, item)
            end
        end

        for _, item in ipairs(PENALTY_REMOVE_ITEMS.trinket) do
            if player:HasTrinket(item) then
                Astro:RemoveAllTrinket(player, item)
            end
        end

        if CheckBossRoom() then
            if player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_EDEN_B):RandomFloat() <= PENALTY_DEATHS_HEAD_CHANCE then
                for i = 1, PENALTY_DEATHS_HEAD_COUNT do
                    Astro:Spawn(EntityType.ENTITY_DEATHS_HEAD, 0, 0, player.Position)
                end
            end

            if not (Astro.IsFight and Astro:IsLatterStage()) then
                player:AddBrokenHearts(PENALTY_BROKEN_HEARTS)
            end
        end
    end
)

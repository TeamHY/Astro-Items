-- TODO: 모든 챔피언(무적 챔피언 제외)이 동일한 확률로 등장하게 됨. 리펜턴스부터 등장한 무지개 챔피언이 너무 자주 나타날 수 있음.

-- 강제 챔피언 제외할 엔티티 타입
local champBanType = {407, 212, 293, 62, 74, 75, 76, 81}

---@param stage LevelStage
---@return boolean
local function CheckHeartLimitStage(stage)
    local level = Game():GetLevel()

    return stage >= LevelStage.STAGE4_3 or
        (stage == LevelStage.STAGE4_2 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE)
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local level = Game():GetLevel()
        local stage = level:GetStage()
        local playerType = player:GetPlayerType()

        if CheckHeartLimitStage(stage) or playerType == PlayerType.PLAYER_JUDAS then
            if
                playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B or
                    playerType == PlayerType.PLAYER_THESOUL_B
             then
            elseif playerType == PlayerType.PLAYER_THEFORGOTTEN then
                player:AddBoneHearts(-player:GetBoneHearts() + 2)
                player:AddBrokenHearts(4 - player:GetBrokenHearts())
                player:GetSubPlayer():AddBrokenHearts(2 - player:GetSubPlayer():GetBrokenHearts())
            elseif playerType == PlayerType.PLAYER_THESOUL then
                player:AddBrokenHearts(2 - player:GetBrokenHearts())
                player:GetSubPlayer():AddBoneHearts(-player:GetSubPlayer():GetBoneHearts() + 2)
                player:GetSubPlayer():AddBrokenHearts(4 - player:GetSubPlayer():GetBrokenHearts())
            else
                if player:GetEffectiveMaxHearts() > 2 then
                    if player:GetMaxHearts() >= 2 then
                        player:AddMaxHearts(2 - player:GetMaxHearts(), true)
                        player:AddBoneHearts(-player:GetBoneHearts())
                    else
                        player:AddBoneHearts(1 - player:GetBoneHearts())
                    end
                end

                if player:GetSoulHearts() > 6 then
                    player:AddSoulHearts(6 - player:GetSoulHearts())
                end

                if player:GetBrokenHearts() < 8 then
                    player:AddBrokenHearts(8 - player:GetBrokenHearts())
                end
            end
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGIC_8_BALL, true) then
            local idx = level:QueryRoomTypeIndex(RoomType.ROOM_PLANETARIUM, false, RNG())
            local room = level:GetRoomByIdx(idx)

            if room.Data.Type == RoomType.ROOM_PLANETARIUM then
                room.DisplayFlags = room.DisplayFlags | 1 << 2
                level:UpdateVisibility()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    ---@param entity Entity
    function(_, entity)
        if CheckHeartLimitStage(Game():GetLevel():GetStage()) then
            local champ = 0

            repeat
                champ = entity:GetDropRNG():RandomInt(26)
            until champ ~= 6

            for i = 1, #champBanType do
                if entity.Type == champBanType[i] then
                    champ = -1
                    break
                end
            end

            if entity:IsVulnerableEnemy() then
                entity:ToNPC():Morph(entity.Type, entity.Variant, entity.SubType, champ)
            end
        end
    end
)
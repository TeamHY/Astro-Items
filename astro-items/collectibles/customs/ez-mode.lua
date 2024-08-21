AstroItems.Collectible.EZ_MODE = Isaac.GetItemIdByName("EZ Mode")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.EZ_MODE, "쉬운 모드", "...", "피격 페널티가 발생하지 않습니다.#소울 하트 1개가 증가됩니다.#후반 스테이지 진입 시 제거됩니다.")
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local level = Game():GetLevel()
        local stage = level:GetStage()

        if stage >= LevelStage.STAGE4_3 or (stage == LevelStage.STAGE4_1 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE) or (stage == LevelStage.STAGE4_2 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE) then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
            
                AstroItems:RemoveAllCollectible(player, AstroItems.Collectible.EZ_MODE)
            end
        end
    end
)

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

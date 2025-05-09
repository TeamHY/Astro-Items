-- 패널티 피격 시 차지 감소
local PENALTY_ACTIVE_ITEMS = {
    [CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS] = 2, -- ex) 피격 시 2 감소
}

-- 패널티 피격 시 아이템 제거
local PENALTY_REMOVE_ITEMS = {
    Astro.Collectible.UNHOLY_MANTLE,
    CollectibleType.COLLECTIBLE_HOLY_MANTLE,
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

    for _, item in ipairs(PENALTY_REMOVE_ITEMS) do
        EID:addDescriptionModifier(
            "AstroPenaltyRemove" .. item,
            function(descObj)
                if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == item then
                    return true
                end
            end,
            function(descObj)
                EID:appendToDescription(descObj, "#{{ColorRed}}패널티 피격 시 아이템이 제거됩니다.")
                return descObj
            end
        )
    end
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

        for _, item in ipairs(PENALTY_REMOVE_ITEMS) do
            if player:HasCollectible(item) then
                Astro:RemoveAllCollectible(player, item)
            end
        end
    end
)

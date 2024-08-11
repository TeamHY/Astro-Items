---

local DELAY_FRAME = 30

local DAMAGE_INCREMENT = 0.005

local SPEED_INCREMENT = 0.005

local TEARS_INCREMENT = 0.005

local LUCK_INCREMENT = 0.005

---

AstroItems.Collectible.AMPLIFYING_MIND = Isaac.GetItemIdByName("Amplifying Mind")
AstroItems.Collectible.CALM_MIND = Isaac.GetItemIdByName("Calm Mind")
AstroItems.Collectible.SWIFT_MIND = Isaac.GetItemIdByName("Swift Mind")
AstroItems.Collectible.BLUE_MIND = Isaac.GetItemIdByName("Blue Mind")
AstroItems.Collectible.LUCKY_MIND = Isaac.GetItemIdByName("Lucky Mind")
AstroItems.Collectible.QUANTUM_MIND = Isaac.GetItemIdByName("Quantum Mind")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.AMPLIFYING_MIND,
        "증폭하는 마음",
        "...",
        "{{Collectible" .. AstroItems.Collectible.CALM_MIND .. "}}Calm Mind, {{Collectible" .. AstroItems.Collectible.SWIFT_MIND .. "}}Swift Mind, {{Collectible" .. AstroItems.Collectible.BLUE_MIND .. "}}Blue Mind, {{Collectible" .. AstroItems.Collectible.LUCKY_MIND .. "}}Lucky Mind, {{Collectible" .. AstroItems.Collectible.QUANTUM_MIND .. "}}Quantum Mind의 증가 수치가 2배로 증가합니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.CALM_MIND,
        "침착한 정신",
        "...",
        "1초 마다 공격력이 0.005 증가합니다. 시작 방에서는 증가하지 않습니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.SWIFT_MIND,
        "신속한 정신",
        "...",
        "1초 마다 이동 속도가 0.005 증가합니다. 시작 방에서는 증가하지 않습니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.BLUE_MIND,
        "우울한 정신",
        "...",
        "1초 마다 연사(고정)가 0.005 증가합니다. 시작 방에서는 증가하지 않습니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.LUCKY_MIND,
        "행운의 정신",
        "...",
        "1초 마다 행운이 0.005 증가합니다. 시작 방에서는 증가하지 않습니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.QUANTUM_MIND,
        "퀀텀 마인드",
        "...",
        "사용 시 방 안에 모든 아이템이 {{Collectible" .. AstroItems.Collectible.CALM_MIND .. "}}Calm Mind, {{Collectible" .. AstroItems.Collectible.SWIFT_MIND .. "}}Swift Mind, {{Collectible" .. AstroItems.Collectible.BLUE_MIND .. "}}Blue Mind, {{Collectible" .. AstroItems.Collectible.LUCKY_MIND .. "}}Lucky Mind 중에 하나로 변경됩니다. 동일한 아이템이 여러개 등장할 수 있습니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local mindSeries = {
            AstroItems.Collectible.CALM_MIND,
            AstroItems.Collectible.SWIFT_MIND,
            AstroItems.Collectible.BLUE_MIND,
            AstroItems.Collectible.LUCKY_MIND
        }

        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local pickup = entity:ToPickup()

                if pickup.SubType ~= 0 then
                    local item = AstroItems:GetRandomCollectibles(mindSeries, rngObj, 1, AstroItems.Collectible.MIRROR_DICE, true)[1]

                    if not item then
                        return {
                            Discharge = false,
                            Remove = false,
                            ShowAnim = false,
                        }
                    end
    
                    pickup:Morph(pickup.Type, pickup.Variant, item, true)
                end
            end
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.QUANTUM_MIND
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local data = AstroItems:GetPersistentPlayerData(player)

        if data then
            if not data["mindSeries"] then
                data["mindSeries"] = {
                    damage = 0,
                    speed = 0,
                    tears = 0,
                    luck = 0
                }
            end
    
            if Game():GetLevel():GetCurrentRoomIndex() ~= 84 and Game():GetFrameCount() % DELAY_FRAME == 0 then
                local isRequiredEvaluation = false

                local amplifyingMindMultiplier = player:HasCollectible(AstroItems.Collectible.AMPLIFYING_MIND) and 2 or 1
    
                if player:HasCollectible(AstroItems.Collectible.CALM_MIND) then
                    data["mindSeries"].damage = data["mindSeries"].damage + DAMAGE_INCREMENT * player:GetCollectibleNum(AstroItems.Collectible.CALM_MIND) * amplifyingMindMultiplier
        
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    isRequiredEvaluation = true
                end
    
                if player:HasCollectible(AstroItems.Collectible.SWIFT_MIND) then
                    data["mindSeries"].speed = data["mindSeries"].speed + SPEED_INCREMENT * player:GetCollectibleNum(AstroItems.Collectible.SWIFT_MIND) * amplifyingMindMultiplier
        
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                    isRequiredEvaluation = true
                end
    
                if player:HasCollectible(AstroItems.Collectible.BLUE_MIND) then
                    data["mindSeries"].tears = data["mindSeries"].tears + TEARS_INCREMENT * player:GetCollectibleNum(AstroItems.Collectible.BLUE_MIND) * amplifyingMindMultiplier
        
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    isRequiredEvaluation = true
                end
    
                if player:HasCollectible(AstroItems.Collectible.LUCKY_MIND) then
                    data["mindSeries"].luck = data["mindSeries"].luck + LUCK_INCREMENT * player:GetCollectibleNum(AstroItems.Collectible.LUCKY_MIND) * amplifyingMindMultiplier
        
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                    isRequiredEvaluation = true
                end
    
                if isRequiredEvaluation then
                    player:EvaluateItems()
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data = AstroItems:GetPersistentPlayerData(player)

		if data and data["mindSeries"] then
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + data["mindSeries"].damage
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + data["mindSeries"].speed
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = AstroItems:AddTears(player.MaxFireDelay, data["mindSeries"].tears)
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + data["mindSeries"].luck
            end
		end
    end
)

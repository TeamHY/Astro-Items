---

local DELAY_FRAME = 30

local DAMAGE_INCREMENT = 0.007

local SPEED_INCREMENT = 0.00095

local TEARS_INCREMENT = 0.0019

local LUCK_INCREMENT = 0.0087

local PENALTY_TIME = 60 * 30

---

Astro.Collectible.AMPLIFYING_MIND = Isaac.GetItemIdByName("Amplifying Mind")
Astro.Collectible.CALM_MIND = Isaac.GetItemIdByName("Calm Mind")
Astro.Collectible.SWIFT_MIND = Isaac.GetItemIdByName("Swift Mind")
Astro.Collectible.BLUE_MIND = Isaac.GetItemIdByName("Blue Mind")
Astro.Collectible.LUCKY_MIND = Isaac.GetItemIdByName("Lucky Mind")
Astro.Collectible.QUANTUM_MIND = Isaac.GetItemIdByName("Quantum Mind")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.AMPLIFYING_MIND,
        "증폭하는 마음",
        "...",
        "{{Collectible" .. Astro.Collectible.CALM_MIND .. "}}Calm Mind, {{Collectible" .. Astro.Collectible.SWIFT_MIND .. "}}Swift Mind, {{Collectible" .. Astro.Collectible.BLUE_MIND .. "}}Blue Mind, {{Collectible" .. Astro.Collectible.LUCKY_MIND .. "}}Lucky Mind, {{Collectible" .. Astro.Collectible.QUANTUM_MIND .. "}}Quantum Mind의 증가 수치가 2배로 증가합니다."
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.CALM_MIND,
        "침착한 정신",
        "...",
        "{{Timer}} 1초마다 {{DamageSmall}}공격력 +0.007" ..
        "#{{ArrowGrayRight}} 시작 방에서는 증가하지 않습니다." ..
        "#{{ArrowGrayRight}} 페널티 피격 시 1분간 증가하지 않습니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다."
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.SWIFT_MIND,
        "신속한 정신",
        "...",
        "{{Timer}} 1초마다 {{SpeedSmall}}이동속도 +0.00095" ..
        "#{{ArrowGrayRight}} 시작 방에서는 증가하지 않습니다." ..
        "#{{ArrowGrayRight}} 페널티 피격 시 1분간 증가하지 않습니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다."
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.BLUE_MIND,
        "우울한 정신",
        "...",
        "{{Timer}} 1초마다 {{TearsSmall}}연사(고정) +0.0019" ..
        "#{{ArrowGrayRight}} 시작 방에서는 증가하지 않습니다." ..
        "#{{ArrowGrayRight}} 페널티 피격 시 1분간 증가하지 않습니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다."
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.LUCKY_MIND,
        "행운의 정신",
        "...",
        "{{Timer}} 1초마다 {{LuckSmall}}행운 +0.0087" ..
        "#{{ArrowGrayRight}} 시작 방에서는 증가하지 않습니다." ..
        "#{{ArrowGrayRight}} 페널티 피격 시 1분간 증가하지 않습니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다."
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.QUANTUM_MIND,
        "퀀텀 마인드",
        "...",
        "사용 시 그 방의 아이템을 {{Collectible" .. Astro.Collectible.CALM_MIND .. "}}Calm Mind, {{Collectible" .. Astro.Collectible.SWIFT_MIND .. "}}Swift Mind, {{Collectible" .. Astro.Collectible.BLUE_MIND .. "}}Blue Mind, {{Collectible" .. Astro.Collectible.LUCKY_MIND .. "}}Lucky Mind 중 하나로 변경합니다. (동일한 아이템이 여러 개 등장할 수 있음)" ..
        "#이동속도가 2.0 이상일 경우 {{Collectible" .. Astro.Collectible.SWIFT_MIND .. "}}Swift Mind는 등장하지 않습니다." ..
        "#Leah가 사용할 경우 충전량이 6칸 남습니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local mindSeries = {
            Astro.Collectible.CALM_MIND,
            Astro.Collectible.SWIFT_MIND,
            Astro.Collectible.BLUE_MIND,
            Astro.Collectible.LUCKY_MIND
        }

        if playerWhoUsedItem.MoveSpeed >= 2 then
            mindSeries = {
                Astro.Collectible.CALM_MIND,
                Astro.Collectible.BLUE_MIND,
                Astro.Collectible.LUCKY_MIND
            }
        end

        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local pickup = entity:ToPickup()

                if pickup.SubType ~= 0 then
                    local item = Astro:GetRandomCollectibles(mindSeries, rngObj, 1, Astro.Collectible.MIRROR_DICE, true)[1]

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

        if playerWhoUsedItem:GetPlayerType() == Astro.Players.LEAH and not playerWhoUsedItem:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
            for i = 0, ActiveSlot.SLOT_POCKET2 do
                if playerWhoUsedItem:GetActiveItem(i) == Astro.Collectible.QUANTUM_MIND then
                    playerWhoUsedItem:SetActiveCharge(6, i)
                end
            end

            return {
                Discharge = false,
                Remove = false,
                ShowAnim = true,
            }
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.QUANTUM_MIND
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local data = Astro:GetPersistentPlayerData(player)

        if data then
            if not data["mindSeries"] then
                data["mindSeries"] = {
                    damage = 0,
                    speed = 0,
                    tears = 0,
                    luck = 0,
                    penaltyTime = 0
                }
            end
    
            if Game():GetLevel():GetCurrentRoomIndex() ~= 84 and Game():GetFrameCount() % DELAY_FRAME == 0 and data["mindSeries"].penaltyTime < Game():GetFrameCount()then
                local isRequiredEvaluation = false

                local amplifyingMindMultiplier = player:HasCollectible(Astro.Collectible.AMPLIFYING_MIND) and 2 or 1
    
                if player:HasCollectible(Astro.Collectible.CALM_MIND) then
                    data["mindSeries"].damage = data["mindSeries"].damage + DAMAGE_INCREMENT * player:GetCollectibleNum(Astro.Collectible.CALM_MIND) * amplifyingMindMultiplier
        
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    isRequiredEvaluation = true
                end
    
                if player:HasCollectible(Astro.Collectible.SWIFT_MIND) then
                    data["mindSeries"].speed = data["mindSeries"].speed + SPEED_INCREMENT * player:GetCollectibleNum(Astro.Collectible.SWIFT_MIND) * amplifyingMindMultiplier
        
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                    isRequiredEvaluation = true
                end
    
                if player:HasCollectible(Astro.Collectible.BLUE_MIND) then
                    data["mindSeries"].tears = data["mindSeries"].tears + TEARS_INCREMENT * player:GetCollectibleNum(Astro.Collectible.BLUE_MIND) * amplifyingMindMultiplier
        
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    isRequiredEvaluation = true
                end
    
                if player:HasCollectible(Astro.Collectible.LUCKY_MIND) then
                    data["mindSeries"].luck = data["mindSeries"].luck + LUCK_INCREMENT * player:GetCollectibleNum(Astro.Collectible.LUCKY_MIND) * amplifyingMindMultiplier
        
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

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data = Astro:GetPersistentPlayerData(player)

		if data and data["mindSeries"] then
			if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + data["mindSeries"].damage
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + data["mindSeries"].speed
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, data["mindSeries"].tears)
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + data["mindSeries"].luck
            end
		end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        local data = Astro:GetPersistentPlayerData(player)

        if data and data["mindSeries"] then
            data["mindSeries"].penaltyTime = Game():GetFrameCount() + PENALTY_TIME
        end
    end
)

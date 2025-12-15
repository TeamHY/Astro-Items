---

local AMPLIFYING_MIND_CHANGE_CHANCE = 0.5

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

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(Astro.Collectible.AMPLIFYING_MIND,
                "증폭하는 마음",
                "의지",
                "{{Quality0}}/{{Quality1}}등급 아이템 등장 시 50% 확률로 아래 아이템 중 하나로 바꿉니다." ..
                "#!!! 소지중일 때 아래 아이템들의 효과 두 배:" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.CALM_MIND .. "}} Calm Mind {{ColorGray}}(공격력 증가){{CR}}" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.BLUE_MIND .. "}} Blue Mind {{ColorGray}}(연사 증가){{CR}}" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.SWIFT_MIND .. "}} Swift Mind {{ColorGray}}(이동속도 증가){{CR}}" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.LUCKY_MIND .. "}} Lucky Mind {{ColorGray}}(행운 증가){{CR}}" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.QUANTUM_MIND .. "}} Quantum Mind"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.CALM_MIND,
                "침착한 정신",
                "압도적인 힘",
                "{{Timer}} 1초마다 {{DamageSmall}}공격력 +0.007" ..
                "#{{ArrowGrayRight}} 시작방에서는 증가하지 않습니다." ..
                "#{{ArrowGrayRight}} 페널티 피격 시 1분간 증가하지 않습니다.",
                -- 중첩 시
                "중첩 가능, 다음 증가량부터 적용"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.SWIFT_MIND,
                "신속한 정신",
                "토끼처럼 가볍게",
                "{{Timer}} 1초마다 {{SpeedSmall}}이동속도 +0.00095" ..
                "#{{ArrowGrayRight}} 시작방에서는 증가하지 않습니다." ..
                "#{{ArrowGrayRight}} 페널티 피격 시 1분간 증가하지 않습니다.",
                -- 중첩 시
                "중첩 가능, 다음 증가량부터 적용"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.BLUE_MIND,
                "우울한 정신",
                "누가 양파를 써나?",
                "{{Timer}} 1초마다 {{TearsSmall}}연사 +0.0019" ..
                "#{{ArrowGrayRight}} 시작방에서는 증가하지 않습니다." ..
                "#{{ArrowGrayRight}} 페널티 피격 시 1분간 증가하지 않습니다.",
                -- 중첩 시
                "중첩 가능, 다음 증가량부터 적용"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.LUCKY_MIND,
                "행운의 정신",
                "행운을 빌어요",
                "{{Timer}} 1초마다 {{LuckSmall}}행운 +0.0087" ..
                "#{{Blank}} (중첩 가능, 다음 증가량부터 적용)" ..
                "#{{ArrowGrayRight}} 시작방에서는 증가하지 않습니다." ..
                "#{{ArrowGrayRight}} 페널티 피격 시 1분간 증가하지 않습니다.",
                -- 중첩 시
                "중첩 가능, 다음 증가량부터 적용"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.QUANTUM_MIND,
                "퀀텀 마인드",
                "집합체",
                "사용 시 그 방의 아이템을 아래 아이템 중 하나로 변경:" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.CALM_MIND .. "}} Calm Mind {{ColorGray}}(공격력 증가){{CR}}" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.BLUE_MIND .. "}} Blue Mind {{ColorGray}}(연사 증가){{CR}}" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.SWIFT_MIND .. "}} Swift Mind {{ColorGray}}(이동속도 증가){{CR}}" ..
                "#{{ArrowGrayRight}} {{Collectible" .. Astro.Collectible.LUCKY_MIND .. "}} Lucky Mind {{ColorGray}}(행운 증가){{CR}}" ..
                "#!!! 동일한 아이템이 여러 개 등장할 수 있으며 {{SpeedSmall}}이동속도가 2.0 이상일 경우 {{Collectible" .. Astro.Collectible.SWIFT_MIND .. "}}Swift Mind는 등장하지 않습니다."
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.QUANTUM_MIND),
                { Astro.Players.LEAH },
                "사용 후 충전량을 6칸 보존",
                nil, "ko_kr", nil
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible, itemPoolType, decrease, seed)
                if Astro:HasCollectible(Astro.Collectible.AMPLIFYING_MIND) then
                    local itemConfigItem = Isaac.GetItemConfig():GetCollectible(selectedCollectible)

                    if itemConfigItem.Quality <= 1 then
                        return false
                    end

                    local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.AMPLIFYING_MIND)
                    local mindSeries = {
                        Astro.Collectible.CALM_MIND,
                        Astro.Collectible.SWIFT_MIND,
                        Astro.Collectible.BLUE_MIND,
                        Astro.Collectible.LUCKY_MIND
                    }

                    if rng:RandomFloat() < AMPLIFYING_MIND_CHANGE_CHANCE then
                        return {
                            reroll = true,
                            newItem = mindSeries[rng:RandomInt(#mindSeries) + 1],
                            modifierName = "Amplifying Mind"
                        }
                    end
                end

                return false
            end
        )
    end
)

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
                    Game():SpawnParticles(pickup.Position + Vector(0, -11), EffectVariant.HALO, 1, 0, nil, nil, 9)
                    
                    local sfx = SFXManager()
                    if SoundEffect.SOUND_ITEM_RAISE and sfx:IsPlaying(SoundEffect.SOUND_ITEM_RAISE) then
                        sfx:Stop(SoundEffect.SOUND_ITEM_RAISE)
                        sfx:Play(SoundEffect.SOUND_DIPLOPIA, 0.75)
                    end
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

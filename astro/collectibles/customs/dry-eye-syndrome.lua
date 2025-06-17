---

-- 추가 공격력 배율 최대치 (0.5 = 150%)
local MAX_MULTIPLIER = 0.5

-- 최대치에 도달하기 위해 걸리는 프레임
local FRAME_COUNT = 10 * 30

---

Astro.Collectible.DRY_EYE_SYNDROME = Isaac.GetItemIdByName("Dry Eye Syndrome")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.DRY_EYE_SYNDROME,
        "안구건조증",
        "...",
        "공격 키를 누르고 있으면 {{DamageSmall}}공격력이 점점 증가합니다. 최대 50%p 증가하고 공격 키를 떼면 원래대로 돌아옵니다." ..
        "#{{ArrowGrayRight}} 중첩이 가능합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.DRY_EYE_SYNDROME) then
                local data = Astro:GetPersistentPlayerData(player)
    
                if Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, 0) > 0 then
                    data["dryEyeSyndromeIsActive"] = true
                elseif Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, 0) > 0 then
                    data["dryEyeSyndromeIsActive"] = true
                elseif Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, 0) > 0 then
                    data["dryEyeSyndromeIsActive"] = true
                elseif Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, 0) > 0 then
                    data["dryEyeSyndromeIsActive"] = true
                else
                    data["dryEyeSyndromeIsActive"] = false
                    data["dryEyeSyndromeMultiplier"] = 0
    
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.DRY_EYE_SYNDROME) then
            local data = Astro:GetPersistentPlayerData(player)
        
            if data["dryEyeSyndromeIsActive"] then
                local maxMultiplier = MAX_MULTIPLIER * player:GetCollectibleNum(Astro.Collectible.DRY_EYE_SYNDROME)
        
                if data["dryEyeSyndromeMultiplier"] == nil then
                    data["dryEyeSyndromeMultiplier"] = 0
                end

                print(Game():GetFrameCount())

                if data["dryEyeSyndromeMultiplier"] < maxMultiplier then
                    -- 플레이어 업데이트는 사실 초당 60프레임이라서 2로 나눔
                    data["dryEyeSyndromeMultiplier"] = math.min(data["dryEyeSyndromeMultiplier"] + (maxMultiplier / FRAME_COUNT / 2), maxMultiplier)
                    
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.MULTIPLY,
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.DRY_EYE_SYNDROME) then
            local data = Astro:GetPersistentPlayerData(player)

            if data["dryEyeSyndromeIsActive"] then
                player.Damage = player.Damage * (data["dryEyeSyndromeMultiplier"] + 1)
            end
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

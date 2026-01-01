Astro.Collectible.TAURUS_EX = Isaac.GetItemIdByName("Taurus EX")

---

local TAURUS_COOLDOWN = 60 * 3    -- 60프레임 기준 n초

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local cooldown = string.format("%.f", TAURUS_COOLDOWN / 60)

            Astro.EID:AddCollectible(
                Astro.Collectible.TAURUS_EX,
                "초 황소자리",
                "나 사나이다",
                "{taurusKeySet} 돌진:" ..
                "#{{ArrowGrayRight}} 그 방의 적을 " .. cooldown .. "초간 석화시킵니다." ..
                "#{{ArrowGrayRight}} 접촉한 적에게 공격력 x4 +28의 피해를 입히고 지나간 길에 빛줄기를 소환합니다." ..
                "#{{ArrowGrayRight}} " .. cooldown .. "초간 이동속도가 +0.28 증가하고 공격불능 무적 상태가 되며 접촉한 적에게 0.5초당 20의 피해를 줍니다." ..
                "#{{TimerSmall}} (쿨타임 " .. cooldown .. "초)",
                -- 중첩 시
                "중첩 시 돌진 상태에서 피격 시 발동 효과를 발동"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.TAURUS_EX,
                "Taurus EX",
                "",
                "{taurusKeySet} makes Isaac dash:" .. 
                "#{{Petrify}} Petrifies all enemies in the room for" .. cooldown .. " seconds" ..
                "#{{Damage}} During a dash, Isaac is invincible and deals 4x his damage +28 and leaving behind beams of light" ..
                "#{{Collectible77}} For " .. cooldown .. " seconds, {{Speed}} +0.28 Speed and Isaac can't shoot but deals 40 contact damage per second" ..
                "#{{Timer}} " .. cooldown .. "seconds cooldown",
                -- Stacks
                "Stacks make dash triggers any on-hit item effects",
                "en_us"
            )
        end
        
        local HotkeyToString = {}
        for key, num in pairs(Keyboard) do
            local keyString = key
            local keyStart, keyEnd = string.find(keyString, "KEY_")
            keyString = string.sub(keyString, keyEnd + 1, string.len(keyString))
            keyString = string.gsub(keyString, "_", " ")
            HotkeyToString[num] = keyString
        end
        local function TaurusExCondition(descObj)
            if descObj.ObjType == 5 and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE then
                return true
            end
            return false
        end
        local function TaurusExCallback(descObj)
            if descObj.ObjSubType == Astro.Collectible.TAURUS_EX and Astro.Data["TaurusExMode"] and Astro.Data["TaurusExKeyBind"] then
                local taurusKey = HotkeyToString[Astro.Data["TaurusExKeyBind"]]
                local append1 = (EID:getLanguage() == "ko_kr") and "이동키를 두번 누르면 누른 방향으로"      or "Double-tapping a movement key"
                local append2 = (EID:getLanguage() == "ko_kr") and taurusKey .. "키를 누르면 이동 방향으로 " or "Tapping a " .. taurusKey .. " key"
                
                if Astro.Data["TaurusExMode"] == 1 then
                    descObj.Description = descObj.Description:gsub("{taurusKeySet}", append1)
                elseif Astro.Data["TaurusExMode"] == 0 then
                    descObj.Description = descObj.Description:gsub("{taurusKeySet}", append2)
                end
            end
            return descObj
        end
        EID:addDescriptionModifier("Taurus EX Modifier", TaurusExCondition, TaurusExCallback)
    end
)

------ 리뉴얼 효과 ------
Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = player:GetData()

            pData._ASTRO_taurusExCool = 0
            pData._ASTRO_taurusExSound = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.TAURUS_EX) then return end
        
        local taurusCooldown = TAURUS_COOLDOWN
        local pData = player:GetData()

        local currentCool = pData._ASTRO_taurusExCool or 0
        pData._ASTRO_taurusExCool = math.min(taurusCooldown, currentCool + 1)

        if pData._ASTRO_taurusExCool >= taurusCooldown and not pData._ASTRO_taurusExSound then
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN)
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)

            local sfx = SFXManager()
            sfx:Play(SoundEffect.SOUND_BEEP, 1, 2, false, 0.8)

            local coolEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, player.Position, Vector.Zero, player)
            local cData = coolEffect:GetData()
            cData._ASTRO_taurusExFollow = true    -- FollowParent()를 쓰면 후광이 안 사라짐
            coolEffect.SpriteScale = Vector(0.5, 0.5)
            coolEffect.Color = Color(1, 0.8, 0.5, 1)
            
            pData._ASTRO_taurusExSound = true
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local eData = effect:GetData()

        if eData._ASTRO_taurusExFollow then
            effect.Position = effect.SpawnerEntity.Position
        end
    end,
    EffectVariant.HALLOWED_GROUND
)

local lastInput = {
    [ButtonAction.ACTION_LEFT] = 0,
    [ButtonAction.ACTION_RIGHT] = 0,
    [ButtonAction.ACTION_UP] = 0,
    [ButtonAction.ACTION_DOWN] = 0
}

local lastTap = {
    [ButtonAction.ACTION_LEFT] = 0,
    [ButtonAction.ACTION_RIGHT] = 0,
    [ButtonAction.ACTION_UP] = 0,
    [ButtonAction.ACTION_DOWN] = 0
}

---@param player EntityPlayer
---@param cooldown number
local function taurusExDash(player, cooldown)
    local noAnim = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME
    player:UseActiveItem(CollectibleType.COLLECTIBLE_WHITE_PONY, noAnim)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, noAnim)
    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    
    local sfx = SFXManager()
    local taurusNum = player:GetCollectibleNum(Astro.Collectible.TAURUS_EX)
    if taurusNum > 1 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, noAnim)
        sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
    end

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        ent:AddFreeze(EntityRef(player), (cooldown / 2), true)    -- 퍼즈 액티브로 하면 적의 투사체가 사라지지 않고 남는 문제가 있음 
    end

    Astro:ScheduleForUpdate(
        function()
            player:SetMinDamageCooldown(30)
        end,
        cooldown / 2
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function()
        local game = Game()
        if game:IsPaused() then return end

        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = player:GetData()

            if player:HasCollectible(Astro.Collectible.TAURUS_EX) then
                local now = Isaac.GetFrameCount()
                local taurusCooldown = TAURUS_COOLDOWN

                if Astro.Data["TaurusExMode"] == 1 then
                    for dir = ButtonAction.ACTION_LEFT, ButtonAction.ACTION_DOWN do
                        local pressed = Input.IsActionTriggered(dir, player.ControllerIndex)

                        if pressed and pData._ASTRO_taurusExCool and pData._ASTRO_taurusExCool >= taurusCooldown then
                            if now - lastInput[dir] < 15 then    -- small time window
                                if now - lastTap[dir] > 20 then
                                    -- dash
                                    local vel = Vector.Zero
                                    if dir == ButtonAction.ACTION_LEFT then vel = Vector(-12, 0)
                                    elseif dir == ButtonAction.ACTION_RIGHT then vel = Vector(12, 0)
                                    elseif dir == ButtonAction.ACTION_UP then vel = Vector(0, -12)
                                    elseif dir == ButtonAction.ACTION_DOWN then vel = Vector(0, 12)
                                    end
                                    player.Velocity = vel

                                    taurusExDash(player, taurusCooldown)
                                    pData._ASTRO_taurusExCool = 0
                                    pData._ASTRO_taurusExSound = false
                                    lastTap[dir] = now
                                end
                            end

                            lastInput[dir] = now
                        end
                    end
                else
                    local pressed = Input.IsButtonTriggered(Astro.Data["TaurusExKeyBind"], player.ControllerIndex) 

                    if pressed and pData._ASTRO_taurusExCool and pData._ASTRO_taurusExCool >= taurusCooldown then
                        taurusExDash(player, taurusCooldown)
                        pData._ASTRO_taurusExCool = 0
                        pData._ASTRO_taurusExSound = false
                    end
                end
            end
        end
    end
)
Astro.Collectible.TAURUS_EX = Isaac.GetItemIdByName("Taurus EX")

---

local TAURUS_COOLDOWN = 60 * 3    -- 60프레임 기준 n초

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.TAURUS_EX,
                "초 황소자리",
                "나 사나이다",
                "이동키를 두번 누르면 누른 방향으로 돌진합니다:" ..
                "#{{ArrowGrayRight}} 접촉한 적에게 공격력 x4 +28의 피해를 입히고 지나간 길에 빛줄기를 소환합니다." ..
                "#{{ArrowGrayRight}} " .. string.format("%.f", TAURUS_COOLDOWN / 60) .. "초간 이동속도가 +0.28 증가하고 공격불능 무적 상태가 되며 접촉한 적에게 0.5초당 20의 피해를 줍니다." ..
                "#{{ArrowGrayRight}} 그 방의 적의 움직임이 30초간 멈추며 공격키를 누르면 효과가 풀립니다." ..
                "#{{TimerSmall}} (쿨타임 3초)",
                -- 중첩 시
                "중첩 시 쿨타임 감소"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.TAURUS_EX,
                "Taurus EX",
                "",
                "Double-tapping a movement key makes Isaac dash" .. 
                "#{{Damage}} During a dash, Isaac is invincible and deals 4x his damage +28 and leaving behind beams of light;" ..
                "#{{ArrowGrayRight}} Receive for " .. string.format("%.f", TAURUS_COOLDOWN / 60) .. "seconds at {{Speed}} +0.28 Speed and Isaac can't shoot but deals 40 contact damage per second;" ..
                "#{{ArrowGrayRight}} Pauses all enemies in the room until Isaac shoots. Enemies unpause after 30 seconds" ..
                "#{{Timer}} 3 seconds cooldown",
                -- 중첩 시
                "Cooldown reduced per stack",
                "en_us"
            )
        end
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
        
        local taurusNum = player:GetCollectibleNum(Astro.Collectible.TAURUS_EX)
        local taurusCooldown = math.ceil(TAURUS_COOLDOWN / taurusNum)
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
                local taurusNum = player:GetCollectibleNum(Astro.Collectible.TAURUS_EX)
                local taurusCooldown = math.ceil(TAURUS_COOLDOWN / taurusNum)

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

                                    local noAnim = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME
                                    player:UseActiveItem(CollectibleType.COLLECTIBLE_WHITE_PONY, noAnim)
                                    player:UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, noAnim)
                                    player:UseActiveItem(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, noAnim)
                                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)

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
                        local noAnim = UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME
                        player:UseActiveItem(CollectibleType.COLLECTIBLE_WHITE_PONY, noAnim)
                        player:UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, noAnim)
                        player:UseActiveItem(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, noAnim)

                        pData._ASTRO_taurusExCool = 0
                        pData._ASTRO_taurusExSound = false
                    end
                end
            end
        end
    end
)
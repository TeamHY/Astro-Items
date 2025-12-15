Astro.Collectible.DECISIVE_STRIKE = Isaac.GetItemIdByName("Decisive Strike")

---

local STRIKE_SPEED = 5    -- 바늘이 1프레임당 n도 돌아감
local ANIMATION_SPEED = STRIKE_SPEED / 3
local PLAYER_COOLDOWN = math.floor(130 * (3 / STRIKE_SPEED))

local DAMAGE_PENALTY = 0.8    -- 실패 시 x0.8배
local DAMAGE_PENALTY_MAX = 0.9    -- 중첩할 때마다 DAMAGE_PENALTY_RELIEF씩, 최대 x0.9까지
local DAMAGE_PENALTY_RELIEF = 0.25

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.DECISIVE_STRIKE,
                "결정적인 일격",
                "아무것도 무서워할 필요 없어",
                "패널티 피격 시 스테이지당 한번 방 안의 모든 적이 멈추며 QTE 이벤트가 발생합니다." ..
                "#QTE는 액티브 아이템 사용 키로 누를 수 있으며;" ..
                "#{{ArrowGrayRight}} 성공 시 피해를 무시하고 가까운 적들을 {{BleedingOut}}출혈시키며 그 방에서 빠르게 감소하는 {{DamageSmall}}공격력과 {{TearsSmall}}연사를 얻습니다." ..
                "#{{Blank}} (대성공 시 더 높은 능력치를 얻음)" ..
                "#{{ArrowGrayRight}} 실패 시 이번 게임에서 영구적으로 중첩되는 {{DamageSmall}}공격력 배율 x" .. DAMAGE_PENALTY .. "을 얻습니다.",
                -- 중첩 시
                "중첩 시 패널티 공격력 배율이 최대 x" .. DAMAGE_PENALTY_MAX .. "까지 완화"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.DECISIVE_STRIKE,
                "Decisive Strike",
                "",
                "Once per floor upon penalty damage, all enemies in the room freeze and a QTE event triggers" ..
                "#QTE can be pressed with the active item key;" ..
                "#{{ArrowGrayRight}} Success: Negates damage, {{BleedingOut}}bleeds nearby enemies, grants rapidly decaying {{Damage}}damage and {{Tears}}tears up for the room" ..
                "#{{Blank}} (Great success grants higher stats)" ..
                "#{{ArrowGrayRight}} Failure: Permanently stacks {{Damage}}damage multiplier x" .. DAMAGE_PENALTY .. " for the run",
                -- Stacks
                "Stacking mitigates penalty damage multiplier up to x" .. DAMAGE_PENALTY_MAX,
                "en_us"
            )
        end
    end
)


------ 칼찌 ------
local skillCheckSfx = SFXManager()
local veryGoodsound = Astro.SoundEffect.SKILL_CHECK_GREAT
local goodSound = Astro.SoundEffect.SKILL_CHECK_GOOD
local advertiseSound = Astro.SoundEffect.SKILL_CHECK_APPEAR

---@param player EntityPlayer
---@param rng RNG
local function SkillCheck(player, rng)
    local pData = player:GetData()
    if not pData["skillCheckSprites"] then
        pData["skillCheckSprites"] = {}
        pData["skillCheckSprites"].disk = Sprite()
        pData["skillCheckSprites"].disk:Load("gfx/ui/skill_check.anm2", true)
        pData["skillCheckSprites"].disk.PlaybackSpeed = ANIMATION_SPEED

        pData["skillCheckSprites"].strike = Sprite()
        pData["skillCheckSprites"].strike:Load("gfx/ui/skill_check.anm2", true)
        pData["skillCheckSprites"].strike.PlaybackSpeed = ANIMATION_SPEED

        pData["skillCheckSprites"].input = Sprite()
        pData["skillCheckSprites"].input:Load("gfx/ui/skill_check.anm2", true)
        pData["skillCheckSprites"].input.PlaybackSpeed = ANIMATION_SPEED
    end

    local sprites = pData["skillCheckSprites"]
    local randomInt = rng:RandomInt(25) * 6
    sprites.disk.Rotation = 90 + randomInt
    sprites.strike.Rotation = 0
    
    pData["TriggeredDecisiveStrike"] = true
    pData["DecisiveStrike_SkillCheckPressed"] = false
    pData["DecisiveStrike_SkillCheckStop"] = false
    pData["DecisiveStrike_PlayedSound"] = false

    sprites.disk:Play("Disk", true)
    sprites.strike:Play("Strike", true)
    sprites.input:Play("Input", true)
end

local game = Game()
Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = player:GetData()

            pData["DecisiveStrike_Penalty"] = pData["DecisiveStrike_Penalty"] or 1
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = player:GetData()

            if pData then
                pData["TriggeredDecisiveStrike"] = false
                pData["DecisiveStrike_Signal"] = false
            end
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    Astro.CallbackPriority.POST_PENALTY,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player ~= nil then
            local pData = player:GetData()

            if damageFlags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS) == 0 then
                if player:HasCollectible(Astro.Collectible.DECISIVE_STRIKE) and not pData["DecisiveStrike_Signal"] then
                    pData["DecisiveStrike_DamageInfo"] = {
                        ["amount"] = amount,
                        ["damageFlags"] = damageFlags,
                        ["source"] = source,
                        ["countdownFrames"] = countdownFrames,
                    }

                    for i, ent in ipairs(Isaac.GetRoomEntities()) do
                        ent:AddFreeze(EntityRef(player), PLAYER_COOLDOWN - 10)
                    end

                    skillCheckSfx:Play(advertiseSound, 3)
                    skillCheckSfx:Play(SoundEffect.SOUND_FLIP_POOF)

                    local rng = player:GetCollectibleRNG(Astro.Collectible.DECISIVE_STRIKE)
                    Astro:ScheduleForUpdate(
                        function()
                            SkillCheck(player, rng)
                            Game():ShakeScreen(20)
                        end,
                        6
                    )
                    
                    local dirVec
                    if source.Entity and source.Entity.Position then
                        dirVec = (player.Position - source.Entity.Position)
                        dirVec = dirVec:Normalized()
                    else
                        dirVec = Vector(rng:RandomFloat() * 2 - 1, rng:RandomFloat() * 2 - 1)
                        if dirVec:Length() == 0 then
                            dirVec = Vector(0, -1)
                        end
                        dirVec = dirVec:Normalized()
                    end
                    player.ControlsCooldown = PLAYER_COOLDOWN
                    player:AnimatePitfallOut()
                    player:AddVelocity(dirVec * 5)
                    player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
                    
                    pData["DecisiveStrike_Signal"] = true
                    return false
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, game:GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local pData = player:GetData()
            local sprites = pData["skillCheckSprites"]

            if pData["TriggeredDecisiveStrike"] then
                local strike_rot = pData["skillCheckSprites"].strike.Rotation
                local disk_rot = pData["skillCheckSprites"].disk.Rotation
                local relative = (strike_rot - disk_rot) % 360    -- debug: print("Relative angle: " .. relative)
            
                if relative < 0 then
                    relative = relative + 360
                end

                if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
                    if not pData["DecisiveStrike_SkillCheckPressed"] then
                        -- 대성공
                        if relative >= 0 and relative < 9 then
                            skillCheckSfx:Play(veryGoodsound, 2)
                            pData["DecisiveStrike_Result"] = 200
                        -- 성공
                        elseif relative >= 9 and relative <= 45 then
                            skillCheckSfx:Play(goodSound, 2)
                            pData["DecisiveStrike_Result"] = 100
                        -- 실패
                        else
                            pData["DecisiveStrike_Result"] = "fail"
                            skillCheckSfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
                            pData["DecisiveStrike_PlayedSound"] = true
                        end
                    end

                    pData["DecisiveStrike_SkillCheckStop"] = true
                elseif not pData["DecisiveStrike_SkillCheckStop"] and relative > 45 then
                    pData["DecisiveStrike_Result"] = "fail"
                end

                if pData["skillCheckSprites"].disk:IsEventTriggered("Invisible") then
                    pData["DecisiveStrike_SkillCheckPressed"] = true

                    Astro:ScheduleForUpdate(
                        function()
                            local damageInfo = pData["DecisiveStrike_DamageInfo"]

                            if pData["DecisiveStrike_Result"] ~= "fail" then
                                player:GetEffects():AddNullEffect(NullItemID.ID_CAMO_BOOST, false, pData["DecisiveStrike_Result"])

                                local entities = Isaac.FindInRadius(player.Position, 120)
                                if #entities > 0 then
                                    for _, ent in ipairs(entities) do
                                        if ent:IsVulnerableEnemy() then
                                            for j = 0, 1 do
                                                game:SpawnParticles(ent.Position, EffectVariant.BLOOD_PARTICLE, 3, 10, Color(1, 1, 1, 1), nil, j)
                                            end
                                            skillCheckSfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
                                            ent:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
                                        end
                                    end
                                end
                            else
                                if not pData["DecisiveStrike_PlayedSound"] then
                                    sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
                                end

                                if damageInfo then
                                    player:TakeDamage(damageInfo["amount"], damageInfo["damageFlags"] | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), damageInfo["countdownFrames"])
                                    player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
                                end

                                pData["DecisiveStrike_Penalty"] = pData["DecisiveStrike_Penalty"] * DAMAGE_PENALTY
                                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                            end
                        end,
                        12
                    )
                end

                local DrawPos = Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2)

                pData["skillCheckSprites"].disk:Update()
                pData["skillCheckSprites"].disk:Render(DrawPos)
                
                pData["skillCheckSprites"].input:Update()
                pData["skillCheckSprites"].input:Render(DrawPos)

                if not pData["DecisiveStrike_SkillCheckStop"] then
                    pData["skillCheckSprites"].strike.Rotation = pData["skillCheckSprites"].strike.Rotation + STRIKE_SPEED
                end
                pData["skillCheckSprites"].strike:Update()
                pData["skillCheckSprites"].strike:Render(DrawPos)
            end
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if cacheFlag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(Astro.Collectible.DECISIVE_STRIKE) then
            local pData = player:GetData()
            local basePenalty = pData["DecisiveStrike_Penalty"]

            if basePenalty and basePenalty < 1 then
                local dsNum = player:GetCollectibleNum(Astro.Collectible.DECISIVE_STRIKE)
                local damageMulti = basePenalty + (DAMAGE_PENALTY_RELIEF * (dsNum - 1))

                player.Damage = player.Damage * math.min(damageMulti, DAMAGE_PENALTY_MAX)
            end
        end
    end
)
Astro.Trinket.FOCUS_BAND = Isaac.GetTrinketIdByName("Focus Band")

------
local SURVIVAL_SOURCE = 100    -- 100 -> 1/100 (1%), 10 -> 1/10 (10%)
local SURVIVAL_LUCK = 1      -- 행운 1당 증가할 확률 (예: 2 -> 2%p)
local SURVIVAL_MAX = 10      -- 최대 발동 확률

local SURVIVAL_COOL = 180    -- 기본 무적 시간 (60프레임)
------


Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDTrinket(
                Astro.Trinket.FOCUS_BAND,
                "기합의 머리띠",
                "마지막 수단",
                "#피격 시 체력이 없을 때 1%의 확률로 피해를 무시하고 3초 동안 무적이 됩니다." ..
                "#{{LuckSmall}} 행운 9 이상일 때 " .. SURVIVAL_MAX .. "% 확률 (행운 1당 +" .. SURVIVAL_LUCK .. "%p)"
            )

            Astro:AddGoldenTrinketDescription(Astro.Trinket.FOCUS_BAND, "", 3, 2)
        end
    end
)

local SURVIVAL_MESSAGE_TIME = 0
local SURVIVAL_PLAYER_INDEX = 0

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()
        local currentHP = player:GetHearts() + player:GetSoulHearts() + player:GetEternalHearts() + player:GetBoneHearts()
        if player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
            currentHP = 0
        end

        if amount >= currentHP then
            if player:HasTrinket(Astro.Trinket.FOCUS_BAND) then
                local luck = math.floor(player.Luck)
                local chancePct = math.min(SURVIVAL_MAX, 1 + (luck * SURVIVAL_LUCK))
                local rng = player:GetTrinketRNG(Astro.Trinket.FOCUS_BAND)

                if rng:RandomInt(SURVIVAL_SOURCE) < chancePct then
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

                    Game():ShakeScreen(15)
                    SFXManager():Play(SoundEffect.SOUND_DEAD_SEA_SCROLLS)

                    player:AddVelocity(dirVec * 6)
                    player:AnimateTrinket(Astro.Trinket.FOCUS_BAND, "Pickup", "PlayerPickupSparkle")
                    player:SetMinDamageCooldown(SURVIVAL_COOL * (player:GetTrinketMultiplier(Astro.Trinket.FOCUS_BAND)))

                    SURVIVAL_MESSAGE_TIME = 180
                    SURVIVAL_PLAYER_INDEX = player.ControllerIndex
                    return false
                end
            end
        end
    end,
    EntityType.ENTITY_PLAYER
)

local messageString = "Isaac hung on!"
local messageFont = Font()
messageFont:Load("resources/font/cjk/lanapixel.fnt")

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function()
        local player = Isaac.GetPlayer(SURVIVAL_PLAYER_INDEX)
        local position = Astro:ToScreen(player.Position)

        if SURVIVAL_MESSAGE_TIME > 0 then
            if Options.Language == "kr" or REPKOR then
                messageString = "아이작은 버텼다!"
            else
                messageString = "Isaac hung on!"
            end

            messageFont:DrawStringUTF8(
                messageString,
                position.X - (messageFont:GetStringWidthUTF8(messageString) / 2),
                position.Y + 10,
                KColor(1, 1, 1, math.min(0.75, SURVIVAL_MESSAGE_TIME / 60)),
                0,
                false
            )

            if not Game():IsPaused() then
                SURVIVAL_MESSAGE_TIME = SURVIVAL_MESSAGE_TIME - 1
            end
        end
    end
)
-- 최대한 비슷하게 그 방 부활을 구현하기 위해 제작되었습니다 // 사왈이

local ghostCharacter = {
    PlayerType.PLAYER_THELOST,
    PlayerType.PLAYER_THESOUL,
    PlayerType.PLAYER_THELOST_B,
    PlayerType.PLAYER_JACOB2_B,
    PlayerType.PLAYER_THESOUL_B
}

---@param player EntityPlayer
---@return boolean
local function IsGwisin(player)
    local pType = player:GetPlayerType()

    for _, ghost in pairs(ghostCharacter) do
        if pType == ghost then
            return true
        elseif player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
            return true
        end
    end

    return false
end

local controlCooldown = 0

---@param player EntityPlayer
---@param damageCooldown number
---@param customSound SoundEffect?
---@param animate CollectibleType
function Astro:FakeDeath(player, damageCooldown, customSound, animate)
    local animationDur = customDur or 37
    local sfx = SFXManager()
    local customSound = customSound or SoundEffect.SOUND_DEATH_BURST_SMALL

    if not IsGwisin(player) then
        sfx:Play(customSound)
        Game():SpawnParticles(player.Position, EffectVariant.BLOOD_SPLAT, 1, 0)

        animationDur = 55
    end

    player:PlayExtraAnimation("Hit")
    sfx:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT)

    Astro:ScheduleForUpdate(function() player:PlayExtraAnimation(IsGwisin(player) and "LostDeath" or "Death") end, 4)
    Astro:ScheduleForUpdate(function() sfx:Play(SoundEffect.SOUND_ISAACDIES) end, 10)

    player:SetMinDamageCooldown(damageCooldown + (animationDur * 2))
    player.ControlsCooldown = animationDur * 2
    controlCooldown = animationDur * 2

    if animate then
        Astro:ScheduleForUpdate(function() player:AnimateCollectible(animate) end, animationDur)
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if controlCooldown > 0 then
            player.Velocity = Vector.Zero
            controlCooldown = controlCooldown - 1
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param inContinued boolean
    function(_, inContinued)
        controlCooldown = 0
    end
)
Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE = Isaac.GetItemIdByName("Sinful Spoils of Subversion - Snake Eye")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE,
        "반역의 죄보 - 스네이크아이",
        "...",
        "공격 시 10%의 확률로{{Collectible634}} Purgatory 유령을 소환합니다." ..
        "#중첩 시 기본 확률이 합 연산으로 증가하고 쿨타임이 줄어듭니다." ..
        "#{{LuckSmall}} 행운 90 이상일 때 100% 확률 (행운 1당 +1%p)"
    )
end

local spawnChance = 0.1

local luckMultiply = 1 / 100

local cooldownTime = 75 -- 30 프레임 = 1초

---@param player EntityPlayer
---@return number
local function ComputeMultiplier(player)
    local result = player:GetCollectibleNum(Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE)

    if player:GetPlayerType() == Astro.Players.DIABELLSTAR then
        result = result + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    return result
end

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil then
            local data = player:GetData()

            if player:HasCollectible(Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE) and entity:IsVulnerableEnemy() and (data["ssosSnakeEyeCooldown"] == nil or data["ssosSnakeEyeCooldown"] < Game():GetFrameCount() or (data["ossDurationTime"] ~= nil and data["ossDurationTime"] > Game():GetFrameCount())) then
                if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                    local rng = player:GetCollectibleRNG(Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE)
                    local baseChance = spawnChance * ComputeMultiplier(player)

                    if rng:RandomFloat() < baseChance + player.Luck * luckMultiply then
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, player.Position, Vector.Zero, player)
                        effect:GetSprite():Play("Charge", false)

                        data["ssosSnakeEyeCooldown"] = Game():GetFrameCount() + cooldownTime / ComputeMultiplier(player)
                    end
                end
            end
        end
    end
)

Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE = Isaac.GetItemIdByName("Original Sinful Spoils - Snake Eye")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE,
        "원죄보 - 스네이크아이", "...",
        "공격 시 10%의 확률로 여러 유령을 소환합니다." ..
        "#{{TimerSmall}} (쿨타임 2.5초)" ..
        "#{{ArrowGrayRight}} 중첩 시 기본 확률이 합 연산으로 증가하고 유령이 소환되는 쿨타임이 줄어듭니다." ..
        "#{{LuckSmall}} 행운 90 이상일 때 100% 확률 (행운 1당 +1%p)")
end

local spawnChance = 0.1

local luckMultiply = 1 / 100

local cooldownTime = 75 -- 30 프레임 = 1초

---@param player EntityPlayer
---@return number
local function ComputeMultiplier(player)
    local result = player:GetCollectibleNum(Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE)

    if player:GetPlayerType() == Astro.Players.DIABELLSTAR_B then
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

            if player:HasCollectible(Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE) and entity:IsVulnerableEnemy() and (data["ossSnakeEyeCooldown"] == nil or data["ossSnakeEyeCooldown"] < Game():GetFrameCount() or (data["ossDurationTime"] ~= nil and data["ossDurationTime"] > Game():GetFrameCount())) then
                if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                    local rng = player:GetCollectibleRNG(Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE)
                    local baseChance = spawnChance * ComputeMultiplier(player);

                    if rng:RandomFloat() < baseChance + player.Luck * luckMultiply then
                        local random = rng:RandomInt(3)

                        if random == 0 then
                            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, player.Position, Vector.Zero, player)
                            effect:GetSprite():Play("Charge", false)
                        elseif random == 1 then
                            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 0, player.Position, Vector.Zero, player)
                            local data = effect:GetData()

                            if not data.Astro then
                                data.Astro = {}
                            end

                            data.Astro.KillFrame = Game():GetFrameCount() + 7 * 30
                        else
                            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, player.Position, Vector.Zero, player)
                            local data = effect:GetData()

                            if not data.Astro then
                                data.Astro = {}
                            end

                            data.Astro.KillFrame = Game():GetFrameCount() + 10 * 30
                        end

                        data["ossSnakeEyeCooldown"] = Game():GetFrameCount() + cooldownTime / ComputeMultiplier(player)
                    end
                end
            end
        end
    end
)

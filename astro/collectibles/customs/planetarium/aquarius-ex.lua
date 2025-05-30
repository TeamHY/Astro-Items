---

local PENALTY_TIME = 10 * 30

---

Astro.Collectible.AQUARIUS_EX = Isaac.GetItemIdByName("Aquarius EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.AQUARIUS_EX,
        "초 물병자리",
        "...",
        "공격 당한 몬스터에서 눈물이 뿜어져 나옵니다." ..
        "#페널티 피격 시 10초 동안 효과가 중지됩니다."
    )
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

        if player ~= nil and player:HasCollectible(Astro.Collectible.AQUARIUS_EX) and entity:IsVulnerableEnemy() then
            if
                source.Type == EntityType.ENTITY_TEAR or
                    damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or
                    source.Type == EntityType.ENTITY_KNIFE
             then
                entity:GetData().Aquarius = {
                    Source = player,
                    Delay = math.floor(7 / player:GetCollectibleNum(Astro.Collectible.AQUARIUS_EX)) --몬스터에게 나오는 눈물 설정하는 곳
                }
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            local data = entity:GetData().Aquarius

            if data ~= nil then
                ---@type EntityPlayer
                local player = data.Source

                if player ~= nil and entity:IsVulnerableEnemy() and Game().TimeCounter % data.Delay == 0 and Astro:GetLastPenaltyFrame(player) + PENALTY_TIME < Game():GetFrameCount() then
                    local splashTear =
                        player:FireTear(
                        entity.Position,
                        Vector(player.ShotSpeed * 10, 0):Rotated(math.random(360)),
                        true,
                        true,
                        false
                    )
                    splashTear.FallingSpeed = player.TearHeight * .5 * (math.random() * .75 + .5)
                    splashTear.FallingAcceleration = 1.3
                    splashTear.TearFlags = splashTear.TearFlags | TearFlags.TEAR_PIERCING
                end
            end
        end
    end
)

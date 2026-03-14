Astro.Collectible.DIVINE_LIGHT = Isaac.GetItemIdByName("Divine Light")

---

local SPAWN_CHANCE = 0.1

local LUCK_MULTIPLY = 1 / 20

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_HOLY_LIGHT].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible208}}{{ColorYellow}}신성한 빛{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible208}} {{ColorYellow}}Holy Light{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.DIVINE_LIGHT, CRAFT_HINT)

            Astro.EID:AddCollectible(
                Astro.Collectible.DIVINE_LIGHT,
                "신의 조명",
                "앞을 밝히노니",
                "적 명중 시 " .. string.format("%.f", SPAWN_CHANCE * 100) .. "%의 확률로 빛줄기를 소환합니다." ..
                "#{{LuckSmall}} 행운 18 이상일 때 100% 확률 (행운 1당 +5%p)",
                -- 중첩 시
                "중첩된 수만큼 빛줄기 소환 시도"
            )
            
            Astro.EID:AddCollectible(
                Astro.Collectible.DIVINE_LIGHT,
                "Divine Light",
                "",
                string.format("%.f", SPAWN_CHANCE * 100) .. "% chance to summon light beams on hit (+5%p per Luck)",
                -- Stacks
                "Stacks summon additional light beams",
                "en_us"
            )

            Astro.EID.LuckFormulas["5.100." .. tostring(Astro.Collectible.DIVINE_LIGHT)] = function(luck, num)
                return (SPAWN_CHANCE + luck * LUCK_MULTIPLY) * 100
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(Astro.Collectible.DIVINE_LIGHT) and entity:IsVulnerableEnemy() then
            if source.Type == EntityType.ENTITY_TEAR or damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or source.Type == EntityType.ENTITY_KNIFE then
                local rng = player:GetCollectibleRNG(Astro.Collectible.DIVINE_LIGHT)

                for _ = 1, player:GetCollectibleNum(Astro.Collectible.DIVINE_LIGHT) do
                    if rng:RandomFloat() < SPAWN_CHANCE + player.Luck * LUCK_MULTIPLY then
                        local light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 1, entity.Position, Vector.Zero, player)
                        light.Parent = player
                        light.CollisionDamage = player.Damage * 3
                    end
                end
            end
        end
    end
)

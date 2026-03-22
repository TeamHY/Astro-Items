Astro.Collectible.GOLD_TOOTH = Isaac.GetItemIdByName("Gold Tooth")

---

local EXTRA_DAMAGE = 3.2

local BASE_CHANCE = 10    -- 기본 확률 1/n으로 설정. 기본값 10, 1/10 = 10%

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            local chanceString = string.format("%.f", (1 / BASE_CHANCE) * 100)

            Astro.EID:AddCollectible(
                Astro.Collectible.GOLD_TOOTH,
                "금이빨",
                "모조리 씹어 먹어줄게",
                "적이 피해를 받을 때마다 " .. chanceString .. "% 확률로 피해량이 " .. EXTRA_DAMAGE .. "배로 증가합니다." .. 
                "#{{LuckSmall}} 행운 " .. BASE_CHANCE - 1 .. " 이상일 때 100% 확률",
                -- 중첩 시
                "중첩 시 피해량 배수가 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.GOLD_TOOTH,
                "Gold Tooth", "",
                "{{Damage}} " .. chanceString .. "% chance to deal by " .. EXTRA_DAMAGE .. "x damage on hit",
                -- Stacks
                "Stackable",
                "en_us"
            )

            Astro.EID.LuckFormulas["5.100." .. tostring(Astro.Collectible.GOLD_TOOTH)] = function(luck, num)
                return (1 / (BASE_CHANCE - math.min(BASE_CHANCE - 1, luck))) * 100
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
        if entity:IsVulnerableEnemy() and source.Entity ~= nil and damageFlags & DamageFlag.DAMAGE_IV_BAG == 0 then
            local player = Astro:GetPlayerFromEntity(source.Entity)
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.GOLD_TOOTH) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.GOLD_TOOTH)
                local num = player:GetCollectibleNum(Astro.Collectible.GOLD_TOOTH)
                local chance = 1 / (BASE_CHANCE - math.min(BASE_CHANCE - 1, player.Luck))

                if rng:RandomFloat() <= chance then
                    entity:TakeDamage(amount * ((EXTRA_DAMAGE * num) - 1), damageFlags | DamageFlag.DAMAGE_IV_BAG, source, countdownFrames)
                end
            end
        end
    end
)
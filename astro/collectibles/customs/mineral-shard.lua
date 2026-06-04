Astro.Collectible.MINERAL_SHARD = Isaac.GetItemIdByName("Mineral Shard")

---

local EXTRA_DAMAGE_MULTI = 0.004

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.MINERAL_SHARD,
                "미네랄 조각",
                "별의 선물",
                "{{Collectible132}} 눈물이 멀리 나갈수록 프레임당 공격력 x0.004씩 증가합니다.",
                -- 중첩 시
                "중첩 시 눈물 피해량의 상승량이 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.MINERAL_SHARD,
                "Mineral Shard", "",
                "{{Collectible132}} Tears deal 0.004x Isaac's damage per frames the further they travel",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end

        -- 미네랄 조각 소지 시 석탄 리롤 로직 추가
        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.MINERAL_SHARD) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_LUMP_OF_COAL,
                        modifierName = "Mineral Shard"
                    }
                end
        
                return false
            end
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_TEAR_INIT,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        
        if player and player:HasCollectible(Astro.Collectible.MINERAL_SHARD) then
            if tear.Variant == TearVariant.BLUE or tear.Variant == TearVariant.BLOOD then
                tear:ChangeVariant(TearVariant.DIAMOND)
            end
        end
    end
)

-- decompiled code by Guantol-Lemat
Astro:AddCallback(
    ModCallbacks.MC_POST_TEAR_UPDATE,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)

        if player and player:HasCollectible(Astro.Collectible.MINERAL_SHARD) then
            local num = player:GetCollectibleNum(Astro.Collectible.MINERAL_SHARD)

            if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
                local tearParams = player:GetTearHitParams(WeaponType.WEAPON_LUDOVICO_TECHNIQUE)
                local tearDmg = tearParams.TearDamage
                local tearPos = tear.Position
                local parentPos = tear.Parent.Position
                local dist = parentPos:Distance(tearPos)
                local clampMax = math.max(100, 700 - tearDmg - (num - 1) * 10)
                local clamped = Astro:Clamp(dist, 1, clampMax)
                local scaleFactor = clamped / clampMax + 1

                tear.CollisionDamage = tearDmg * scaleFactor
                tear.Scale = tearParams.TearScale * 1.9 * scaleFactor
                
                if tear.Variant == TearVariant.BLUE or tear.Variant == TearVariant.BLOOD then
                    tear:ChangeVariant(TearVariant.DIAMOND)
                end
            elseif tear.WaitFrames < 1 then
                local len = tear.PosDisplacement:Length()
                
                tear.CollisionDamage = tear.CollisionDamage + len * player.Damage * EXTRA_DAMAGE_MULTI * num
                tear.Scale = tear.BaseScale + 0.01
            end
        end
    end
)
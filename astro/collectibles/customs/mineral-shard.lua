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
                "{{Collectible132}} 공격이 멀리 나갈수록 타일 1칸당 피해량이 공격력 x0.6 증가합니다." ..
                "#눈물의 피해량이 초당 +15.5 증가합니다.",
                -- 중첩 시
                "중첩 시 눈물 피해량의 상승량이 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.MINERAL_SHARD,
                "Mineral Shard", "",
                "{{Collectible132}} Attacks deal +0.6 damage per tile the further they travel" ..
                "{{Damage}} Tears deal +15.5 damage per seconds",
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
            if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
                local tearParams = player:GetTearHitParams(WeaponType.WEAPON_LUDOVICO_TECHNIQUE)
                local tearDmg = tearParams.TearDamage
                local tearPos = tear.Position
                local parentPos = tear.Parent.Position
                local dist = parentPos:Distance(tearPos)
                local clampMax = math.max(100, 700 - tearDmg)
                local clamped = Astro:Clamp(dist, 1, clampMax)
                local scaleFactor = clamped / clampMax + 1

                tear.CollisionDamage = tearDmg * scaleFactor
                tear.Scale = tearParams.TearScale * 1.9 * scaleFactor
                
                if tear.Variant == TearVariant.BLUE or tear.Variant == TearVariant.BLOOD then
                    tear:ChangeVariant(TearVariant.DIAMOND)
                end
            elseif tear.WaitFrames < 1 then
                local len = tear.PosDisplacement:Length()
                
                tear.CollisionDamage = tear.CollisionDamage + len * player.Damage * EXTRA_DAMAGE_MULTI
                tear.Scale = tear.BaseScale + 0.01
            end
        end
    end
)
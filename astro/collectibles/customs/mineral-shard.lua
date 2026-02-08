Astro.Collectible.MINERAL_SHARD = Isaac.GetItemIdByName("Mineral Shard")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.MINERAL_SHARD,
                "미네랄 조각",
                "별의 선물",
                "{{Collectible132}} 공격이 멀리 나갈수록 타일 1칸당 피해량이 +0.6 증가합니다." ..
                "#눈물과 캐릭터의 거리가 멀수록 타일 1칸당 눈물의 피해량이 +1.2 증가합니다.",
                -- 중첩 시
                "중첩 시 눈물 피해량의 상승량이 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.MINERAL_SHARD,
                "Mineral Shard", "",
                "{{Collectible132}} Attacks deal +0.6 damage per tile the further they travel" ..
                "{{Damage}} Tears deal +1.2 damage per tile based on the distance from Isaac",
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
            if not player:HasCollelctible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) and tear.Variant == TearVariant.BLUE or tear.Variant == TearVariant.BLOOD then
                tear:ChangeVariant(TearVariant.DIAMOND)
            end

            local tearData = tear:GetData()
            tearData._ASTRO_baseDamage = tear.CollisionDamage
            tearData._ASTRO_baseScale = tear.Scale
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_TEAR_UPDATE,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)

        if player and player:HasCollectible(Astro.Collectible.MINERAL_SHARD) then
            local playerPos = player.Position
            local tearPos = tear.Position
            local dist = playerPos:Distance(tearPos)

            local tearData = tear:GetData()
            if tearData._ASTRO_baseDamage and tearData._ASTRO_baseScale then
                tear.CollisionDamage = tearData._ASTRO_baseDamage + (dist / 25)
                tear.Scale = tearData._ASTRO_baseScale + (dist / 1000)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.MINERAL_SHARD) and cacheFlag == CacheFlag.CACHE_TEARFLAG then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_GROW
        end
    end
)
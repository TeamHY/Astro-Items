Astro.Collectible.EYE_OF_MICHAEL = Isaac.GetItemIdByName("Eye of Michael")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.EYE_OF_MICHAEL,
                "미카엘의 눈",
                "...",
                "공격이 적을 관통하며;" ..
                "#{{ArrowGrayRight}} 관통한 눈물 공격은 후광이 생기고 후광에 닿은 적은 초당 60의 피해를 받습니다.",
                -- 중첩 시
                "공격이 유도됩니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.EYE_OF_MICHAEL,
                "Eye of Michael",
                "...",
                "Tears pierce;" ..
                "#{{ArrowGrayRight}} Piercing tears gain {{Collectible331}} Godhead aura, dealing 60 damage per second to enemies in it.",
                -- Stacks
                "Tears become homing.",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param flag CacheFlag
    function(_, player, flag)
        if player:HasCollectible(Astro.Collectible.EYE_OF_MICHAEL) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING

            if player:GetCollectibleNum(Astro.Collectible.EYE_OF_MICHAEL) >= 2 then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
            end
        end
    end,
    CacheFlag.CACHE_TEARFLAG
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_TEAR_COLLISION,
    ---@param tear EntityTear
    ---@param entity Entity
    function(_, tear, entity)
        if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
            local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
            if player and player:HasCollectible(Astro.Collectible.EYE_OF_MICHAEL) then
                if not tear:HasTearFlags(TearFlags.TEAR_GROW) then
                    tear:AddTearFlags(TearFlags.TEAR_GLOW)

                    -- 이펙트 버그 방지용
                    tear.Visible = false
                    Astro:ScheduleForUpdate(
                        function()
                            if tear:Exists() then
                                tear.Visible = true
                            end
                        end,
                        2
                    )
                end
            end
        end
    end
)

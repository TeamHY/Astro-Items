Astro.Trinket.EDENS_SNAKE = Isaac.GetTrinketIdByName("Eden's Snake")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddTrinket(
                Astro.Trinket.EDENS_SNAKE,
                "에덴의 뱀",
                "선악과",
                "#{{Collectible381}} 소지중인 상태에서 {{MegaSatanSmall}}Mega Satan, {{DeliriumSmall}}Delirium, {{MotherSmall}}Mother, {{Collectible633}}Dogma 처치시 Eden's Blessing을 1개 획득합니다." ..
                "#!!! 피격 시 흡수됩니다." ..
                "#!!! 효과 발동 시 사라집니다."
            )

            Astro.EID:AddTrinket(
                Astro.Trinket.EDENS_SNAKE,
                "Eden's Snake",
                "선악과",
                "Defeating {{MegaSatan}}Mega Satan, {{Delirium}}Delirium, {{Mother}}Mother, and {{Collectible633}}Dogma grants an Eden's Blessing" ..
                "#!!! Absorbed when hit." ..
                "#!!! Disappeared after triggering",
                nil, "en_us"
            )

            Astro:AddGoldenTrinketDescription(Astro.Trinket.EDENS_SNAKE, "", 1, 2)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)

            if
                player:HasTrinket(Astro.Trinket.EDENS_SNAKE) and
                    (npc.Type == EntityType.ENTITY_MEGA_SATAN_2 or npc.Type == EntityType.ENTITY_DELIRIUM or
                        npc.Type == EntityType.ENTITY_MOTHER or npc.Type == EntityType.ENTITY_DOGMA)
             then
                player:AddCollectible(CollectibleType.COLLECTIBLE_EDENS_BLESSING)

                if player:GetTrinketMultiplier(Astro.Trinket.EDENS_SNAKE) > 1 then
                    player:AddCollectible(CollectibleType.COLLECTIBLE_EDENS_BLESSING)
                end

                player:TryRemoveTrinket(Astro.Trinket.EDENS_SNAKE)
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
        local player = entity:ToPlayer()

        if player then
            local trinket0 = player:GetTrinket(0)
            local trinket1 = player:GetTrinket(1)

            if trinket0 ~= 0 then
                player:TryRemoveTrinket(trinket0)
            end

            if trinket1 ~= 0 then
                player:TryRemoveTrinket(trinket1)
            end

            if trinket0 ~= 0 then
                if trinket0 == Astro.Trinket.EDENS_SNAKE then
                    Astro:SmeltTrinket(player, trinket0)
                else
                    player:AddTrinket(trinket0)
                end
            end

            if trinket1 ~= 0 then
                if trinket1 == Astro.Trinket.EDENS_SNAKE then
                    Astro:SmeltTrinket(player, trinket1)
                else
                    player:AddTrinket(trinket1)
                end
            end
        end
    end
)

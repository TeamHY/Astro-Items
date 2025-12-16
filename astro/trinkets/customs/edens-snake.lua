Astro.Trinket.EDENS_SNAKE = Isaac.GetTrinketIdByName("Eden's Snake")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDTrinket(
                Astro.Trinket.EDENS_SNAKE,
                "에덴의 뱀",
                "선악과",
                "#{{Collectible381}} 소지중인 상태에서 {{MegaSatanSmall}}Mega Satan, {{DeliriumSmall}}Delirium, {{MotherSmall}}Mother, {{Collectible633}}Dogma 처치시 Eden's Blessing을 1개 소환(획득)합니다." ..
                "#!!! 효과 발동 시 사라집니다."
            )

            Astro:AddEIDTrinket(
                Astro.Trinket.EDENS_SNAKE,
                "Eden's Snake",
                "선악과",
                "Defeating {{MegaSatan}}Mega Satan, {{Delirium}}Delirium, {{Mother}}Mother, and {{Collectible633}}Dogma spawns an Eden's Blessing" ..
                "#!!! Disappeared after triggering",
                nil, "en_us"
            )

            Astro:AddGoldenTrinketDescription(Astro.Trinket.EDENS_SNAKE, "", 1, 2)
        end
    end
)

local GRID_SIZE = 40

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        local currentRoom = Game():GetLevel():GetCurrentRoom()

        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)

            if
                player:HasTrinket(Astro.Trinket.EDENS_SNAKE) and
                    (npc.Type == EntityType.ENTITY_MEGA_SATAN_2 or npc.Type == EntityType.ENTITY_DELIRIUM or
                        npc.Type == EntityType.ENTITY_MOTHER)
             then
                Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_EDENS_BLESSING, player.Position)

                if player:GetTrinketMultiplier(Astro.Trinket.EDENS_SNAKE) > 1 then
                    Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_EDENS_BLESSING, player.Position)
                end

                player:TryRemoveTrinket(Astro.Trinket.EDENS_SNAKE)
            elseif player:HasTrinket(Astro.Trinket.EDENS_SNAKE) and npc.Type == EntityType.ENTITY_DOGMA then
                player:AddCollectible(CollectibleType.COLLECTIBLE_EDENS_BLESSING)

                if player:GetTrinketMultiplier(Astro.Trinket.EDENS_SNAKE) > 1 then
                    player:AddCollectible(CollectibleType.COLLECTIBLE_EDENS_BLESSING)
                end

                player:TryRemoveTrinket(Astro.Trinket.EDENS_SNAKE)
            end
        end
    end
)

Astro.Trinket.EDENS_SNAKE = Isaac.GetTrinketIdByName("Eden's Snake")

if EID then
    Astro:AddEIDTrinket(
        Astro.Trinket.EDENS_SNAKE,
        "!!! 효과가 발동된 뒤 사라집니다." ..
        "#소지중인 상태에서 {{MegaSatanSmall}}Mega Satan, {{DeliriumSmall}}Delirium, {{MotherSmall}}Mother 처치 시 {{Collectible381}}Eden's Blessing 1개를 소환합니다." ..
        "#Dogma 처치 시 {{Collectible381}}Eden's Blessing 1개를 획득합니다.",
        "에덴의 뱀", "..."
    )

    Astro:AddGoldenTrinketDescription(Astro.Trinket.EDENS_SNAKE, "", 1, 2)
end

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

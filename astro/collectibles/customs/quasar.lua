Astro.Collectible.QUASAR = Isaac.GetItemIdByName("Quasar")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.QUASAR,
        "퀘이사",
        "...",
        "방마다 처음으로 죽은 적의 위치에 블랙홀을 소환합니다." ..
        "#방 클리어 시 10초 동안 무적이 됩니다." ..
        "#2개 이상 소지 시 방을 입장 할 때에도 10초 동안 무적이 됩니다."
    )
end

local remaining = 0

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        remaining = 1

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local quasarNum = player:GetCollectibleNum(Astro.Collectible.QUASAR)

            if not Game():GetRoom():IsClear() and quasarNum >= 2 then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.QUASAR) and remaining > 0 and entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLACK_HOLE, 0, entityNPC.Position, Vector.Zero,
                    player)

                remaining = remaining - 1

                break
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.QUASAR) then
                -- local entities = Isaac.GetRoomEntities()

                -- for _, entity in ipairs(entities) do
                --     if entity.Type ~= EntityType.ENTITY_EFFECT and entity.Variant == EffectVariant.BLACK_HOLE then
                --         entity:Remove()
                --     end
                -- end

                player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)

                -- break
            end
        end
    end
)

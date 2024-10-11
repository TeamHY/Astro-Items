AstroItems.Collectible.DRACOBACK = Isaac.GetItemIdByName("Dracoback, the Rideable Dragon")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.DRACOBACK,
        "기룡 드라코백",
        "...",
        "방 입장 시 적 하나가 지워집니다. 중첩 시 지워지는 적의 수가 증가합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if not Game():GetRoom():IsClear() then
                local entities = AstroItems:Filter(Isaac.GetRoomEntities(), function(entity)
                    return entity:IsVulnerableEnemy() and not entity:IsBoss() and entity.Type ~= EntityType.ENTITY_FIREPLACE
                end)

                local rng = player:GetCollectibleRNG(AstroItems.Collectible.DRACOBACK)

                for _ = 1, math.min(#entities, player:GetCollectibleNum(AstroItems.Collectible.DRACOBACK)) do
                    local index = rng:RandomInt(#entities) + 1
                    local entity = entities[index]

                    Isaac.Spawn(
                        EntityType.ENTITY_TEAR,
                        TearVariant.ERASER,
                        0,
                        entity.Position,
                        Vector.Zero,
                        player
                    )

                    table.remove(entities, index)
                end
            end
        end
    end
)

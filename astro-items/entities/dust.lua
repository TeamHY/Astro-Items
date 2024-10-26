local EFFECT_DUST_VARIANT = Isaac.GetEntityVariantByName("Effect Dust");

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:GetPlayerType() == AstroItems.Players.STELLAR_B then
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EFFECT_DUST_VARIANT,
                    0,
                    player.Position,
                    Vector.Zero,
                    player
                )
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local player = AstroItems:GetPlayerFromEntity(effect)

        effect.Position = player.Position + Vector(0, -34)
    end,
    EFFECT_DUST_VARIANT
)

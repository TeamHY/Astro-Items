AstroItems.Collectible.ABSOLUT_GUPPY = Isaac.GetItemIdByName("Absolut Guppy")
AstroItems.Collectible.DELIRIUM_GUPPY = Isaac.GetItemIdByName("Delirium Guppy")

AstroItems:AddEIDCollectible(AstroItems.Collectible.ABSOLUT_GUPPY, "앱솔루트 구피", "...", "파란 아군 파리가 2배로 소환됩니다.")
AstroItems:AddEIDCollectible(AstroItems.Collectible.DELIRIUM_GUPPY, "섬망 구피", "...", "파란 아군 파리 대신 하얀 아군 파리가 소환됩니다.")

local ABSOLUT_GUPPY_SUBTYPE = 1000
local DELIRIUM_FLY_COLOR = Color(1, 1, 1, 1, 1, 1, 1)

local isStarted = false

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        isStarted = true
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_GAME_EXIT,
    ---@param shouldSave boolean
    function(_, shouldSave)
        isStarted = false
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        if familiar.Variant == FamiliarVariant.BLUE_FLY and familiar.SubType == 0 then
            local absolutFly;

            if isStarted and AstroItems:HasCollectible(AstroItems.Collectible.ABSOLUT_GUPPY) then
                absolutFly = Isaac.Spawn(
                    EntityType.ENTITY_FAMILIAR,
                    FamiliarVariant.BLUE_FLY,
                    ABSOLUT_GUPPY_SUBTYPE,
                    familiar.Position,
                    Vector.Zero,
                    familiar.SpawnerEntity
                )
            end

            if AstroItems:HasCollectible(AstroItems.Collectible.DELIRIUM_GUPPY) then
                familiar.Color = DELIRIUM_FLY_COLOR

                if absolutFly then
                    absolutFly.Color = DELIRIUM_FLY_COLOR
                end
            end
        elseif familiar.Variant == FamiliarVariant.BLUE_FLY and familiar.SubType == ABSOLUT_GUPPY_SUBTYPE then
            familiar.Color = DELIRIUM_FLY_COLOR
        end
    end
)

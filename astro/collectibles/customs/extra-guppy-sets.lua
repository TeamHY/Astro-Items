local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.ABSOLUT_GUPPY = Isaac.GetItemIdByName("Absolut Guppy")
Astro.Collectible.DELIRIUM_GUPPY = Isaac.GetItemIdByName("Delirium Guppy")

Astro:AddEIDCollectible(Astro.Collectible.ABSOLUT_GUPPY, "앱솔루트 구피", "...", "파란 아군 파리가 2배로 소환됩니다.")
Astro:AddEIDCollectible(Astro.Collectible.DELIRIUM_GUPPY, "섬망 구피", "...", "획득 시 {{Trinket117}}Locust of Conquest를 소환합니다.#파란 아군 파리 대신 하얀 아군 파리가 소환됩니다.#적이 죽은 위치에 하얀 아군 파리가 소환됩니다.")

local ABSOLUT_GUPPY_SUBTYPE = 1000
local DELIRIUM_FLY_COLOR = Color(1, 1, 1, 1, 1, 1, 1)

local isStarted = false

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        isStarted = true
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_GAME_EXIT,
    ---@param shouldSave boolean
    function(_, shouldSave)
        isStarted = false
    end
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        if familiar.Variant == FamiliarVariant.BLUE_FLY and familiar.SubType == 0 then
            local absolutFly;

            if isStarted and Astro:HasCollectible(Astro.Collectible.ABSOLUT_GUPPY) then
                absolutFly = Isaac.Spawn(
                    EntityType.ENTITY_FAMILIAR,
                    FamiliarVariant.BLUE_FLY,
                    ABSOLUT_GUPPY_SUBTYPE,
                    familiar.Position,
                    Vector.Zero,
                    familiar.SpawnerEntity
                )
            end

            if Astro:HasCollectible(Astro.Collectible.DELIRIUM_GUPPY) then
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

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param npc EntityNPC
    function(_, npc)
        for _ = 1, Astro:GetCollectibleNum(Astro.Collectible.DELIRIUM_GUPPY) do
            local blueFly = Isaac.Spawn(
                EntityType.ENTITY_FAMILIAR,
                FamiliarVariant.BLUE_FLY,
                0,
                npc.Position,
                Vector.Zero,
                npc
            )

            blueFly.Color = DELIRIUM_FLY_COLOR
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.DELIRIUM_GUPPY) then
            Astro:SpawnTrinket(TrinketType.TRINKET_LOCUST_OF_CONQUEST, player.Position)
        end
    end,
    Astro.Collectible.DELIRIUM_GUPPY
)

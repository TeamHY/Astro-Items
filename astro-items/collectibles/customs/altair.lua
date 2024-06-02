local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.ALTAIR = Isaac.GetItemIdByName("Altair")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.ALTAIR,
        "알타일",
        "...",
        "획득 시 {{Trinket23}}Missing Poster 를 소환합니다.#다음 게임 시작 시 하얀불을 소환합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.RunAltair then
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            Isaac.Spawn(EntityType.ENTITY_FIREPLACE, 4, 0, currentRoom:GetCenterPos(), Vector.Zero, nil)

            AstroItems.Data.RunAltair = false
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.ALTAIR) then
            AstroItems:SpawnTrinket(TrinketType.TRINKET_MISSING_POSTER, player.Position)
        end

        AstroItems.Data.RunAltair = true
    end,
    AstroItems.Collectible.ALTAIR
)

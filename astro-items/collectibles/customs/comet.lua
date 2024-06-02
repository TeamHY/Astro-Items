local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.COMET = Isaac.GetItemIdByName("Comet")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.COMET,
        "혜성",
        "...",
        "획득  {{Card78}}Cracked Key가 하나 드랍됩니다.#다음 게임 시작 시 {{Card78}}Cracked Key을 하나 소환합니다.#중첩이 가능합니다.#맵에 {{UltraSecretRoom}}특급 비밀방의 위치가 표시됩니다."
    )
end

-- https://steamcommunity.com/sharedfiles/filedetails/?id=2557887449
local function DisplayUltraSecretRoom()
    local level = Game():GetLevel()

    for i = 0, 169 do
        local room = level:GetRoomByIdx(i)

        if room.Data and room.Data.Type == RoomType.ROOM_ULTRASECRET then
            room.DisplayFlags = room.DisplayFlags | RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON
            level:UpdateVisibility()
            return
        end
    end
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.CometCount ~= nil and AstroItems.Data.CometCount > 0 then
            local player = Isaac.GetPlayer()
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            for _ = 1, AstroItems.Data.CometCount do
                Isaac.Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TAROTCARD,
                    Card.CARD_CRACKED_KEY,
                    currentRoom:FindFreePickupSpawnPosition(player.Position, 40, true),
                    Vector.Zero,
                    nil
                )
            end

            AstroItems.Data.CometCount = 0
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.COMET) then
                DisplayUltraSecretRoom()
                break
            end
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.COMET) then
            AstroItems:SpawnCard(Card.CARD_CRACKED_KEY, player.Position)
        end

        DisplayUltraSecretRoom()

        AstroItems.Data.CometCount = player:GetCollectibleNum(AstroItems.Collectible.COMET)
    end,
    AstroItems.Collectible.COMET
)

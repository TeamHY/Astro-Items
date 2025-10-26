local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.COMET = Isaac.GetItemIdByName("Comet")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.COMET,
        "혜성",
        "어두운 곳에서의 손님",
        "{{Card78}} 획득 시 Cracked Key가 드랍되며;" ..
        "#{{ArrowGrayRight}} 다음 게임에서 첫 스테이지에 Cracked Key를 하나 소환합니다." ..
        "#{{UltraSecretRoom}} 맵에 특급비밀방의 위치가 표시됩니다.",
        -- 중첩 시
        "중첩 시 중첩된 수만큼 Cracked Key 소환"
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

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.CometCount ~= nil and Astro.Data.CometCount > 0 then
            local player = Isaac.GetPlayer()
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            for _ = 1, Astro.Data.CometCount do
                Isaac.Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TAROTCARD,
                    Card.CARD_CRACKED_KEY,
                    currentRoom:FindFreePickupSpawnPosition(player.Position, 40, true),
                    Vector.Zero,
                    nil
                )
            end

            Astro.Data.CometCount = 0
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.COMET) then
                DisplayUltraSecretRoom()
                break
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.COMET) then
            Astro:SpawnCard(Card.CARD_CRACKED_KEY, player.Position)
        end

        DisplayUltraSecretRoom()

        Astro.Data.CometCount = player:GetCollectibleNum(Astro.Collectible.COMET)
    end,
    Astro.Collectible.COMET
)

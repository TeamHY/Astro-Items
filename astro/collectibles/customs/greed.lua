local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.GREED = Isaac.GetItemIdByName("Greed")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.GREED,
        "탐욕",
        "$",
        "!!! 획득 시 Ultra Greedier가 있는 {{ErrorRoom}}오류방으로 이동하며 {{Collectible223}}Pyromaniac과 {{Collectible375}}Host Hat을 제거합니다."
    )
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Isaac.ExecuteCommand("goto s.error.0")

        player:RemoveCollectible(Astro.Collectible.GREED)

        Astro:RemoveAllCollectible(player, CollectibleType.COLLECTIBLE_PYROMANIAC)
        Astro:RemoveAllCollectible(player, CollectibleType.COLLECTIBLE_HOST_HAT)
    end,
    Astro.Collectible.GREED
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function(_)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()
        local currentRoomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())

        if currentRoom:GetType() == RoomType.ROOM_ERROR and currentRoomDesc.Data.Variant == 0 then
            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_BIGCHEST,
                0,
                currentRoom:GetCenterPos(),
                Vector(0, 0),
                nil
            )
        end
    end
)

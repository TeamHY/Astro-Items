local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.LUNA_EX = Isaac.GetItemIdByName("LUNA EX")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.LUNA_EX,
        "초 달",
        "찬란한 축복을 그대에게",
        "!!! 획득 이후 {{Collectible589}}Luna 미등장" ..
        "#{{Collectible589}} Luna, {{Collectible76}} X-Ray Vision 효과가 적용됩니다." ..
        "#맵에 {{SecretRoom}}비밀방, {{SuperSecretRoom}}일급비밀방, {{UltraSecretRoom}}특급비밀방 위치가 표시됩니다."
    )
end

local function DisplaySecretRoom()
    local level = Game():GetLevel()

    for i = 0, 169 do
        local room = level:GetRoomByIdx(i)

        if room.Data then
            if room.Data.Type == RoomType.ROOM_SECRET or room.Data.Type == RoomType.ROOM_SUPERSECRET or room.Data.Type == RoomType.ROOM_ULTRASECRET then
                room.DisplayFlags = room.DisplayFlags | RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON
            end
        end
    end

    level:UpdateVisibility()
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.LUNA_EX) then
            DisplaySecretRoom()
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_LUNA)

        DisplaySecretRoom()

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_LUNA) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_LUNA)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_XRAY_VISION)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_BLUE_MAP)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    Astro.Collectible.LUNA_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_LUNA) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_LUNA)
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_XRAY_VISION)
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_BLUE_MAP)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    Astro.Collectible.LUNA_EX
)

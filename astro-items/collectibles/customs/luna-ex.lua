local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.LUNA_EX = Isaac.GetItemIdByName("LUNA EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.LUNA_EX,
        "초 달",
        "...",
        "{{Collectible589}}Luna 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#{{Collectible76}}X-Ray Vision 효과가 적용됩니다." ..
        "#{{Collectible" .. AstroItems.Collectible.RAPID_ROCK_BOTTOM .. "}}Rapid Rock Bottom 효과가 적용됩니다." ..
        "#맵에 {{SecretRoom}}비밀방, {{SuperSecretRoom}}일급 비밀방, {{UltraSecretRoom}}특급 비밀방 위치가 표시됩니다."
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

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if AstroItems:HasCollectible(AstroItems.Collectible.LUNA_EX) then
            DisplaySecretRoom()
        end
    end
)

AstroItems:AddCallbackCustom(
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
            hiddenItemManager:Add(player, AstroItems.Collectible.RAPID_ROCK_BOTTOM)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    AstroItems.Collectible.LUNA_EX
)

-- AstroItems:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_LUNA) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_LUNA)
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_XRAY_VISION)
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_BLUE_MAP)
--             hiddenItemManager:Remove(player, AstroItems.Collectible.RAPID_ROCK_BOTTOM)
--             Game():GetLevel():UpdateVisibility()
--         end
--     end,
--     AstroItems.Collectible.LUNA_EX
-- )

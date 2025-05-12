local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.WARD = Isaac.GetItemIdByName("Ward")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.WARD,
                "와드",
                "...",
                "사용 시 그 방과, 다음 방 한번까지 {{Collectible91}}Spelunker Hat, {{Collectible" .. Astro.Collectible.PURPLE_CANDLE .."}}Purple Candle 효과가 적용됩니다."
            )
        end
    end
)

---@param range number
---@param centerRoomIndex number
local function DisplayWardRoom(range, centerRoomIndex)
    local level = Game():GetLevel()

    local centerPos = Astro:ConvertRoomIndexToPosition(centerRoomIndex)

    for i = -range, range do
        for j = -range, range do
            local index = Astro:ConvertRoomPositionToIndex(Vector(centerPos.X + i, centerPos.Y + j))

            if index ~= -1 then
                local room = level:GetRoomByIdx(index)

                if room.Flags & RoomDescriptor.FLAG_RED_ROOM ~= RoomDescriptor.FLAG_RED_ROOM and room.DisplayFlags & RoomDescriptor.DISPLAY_BOX ~= RoomDescriptor.DISPLAY_BOX then
                    room.DisplayFlags = room.DisplayFlags | RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON
                end
            end
        end
    end

    level:UpdateVisibility()
end


Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local currentRoomIndex = Game():GetLevel():GetCurrentRoomIndex()
        DisplayWardRoom(1, currentRoomIndex)

        hiddenItemManager:AddForRoom(playerWhoUsedItem, CollectibleType.COLLECTIBLE_SPELUNKER_HAT)
        hiddenItemManager:AddForRoom(playerWhoUsedItem, Astro.Collectible.PURPLE_CANDLE)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.WARD
)

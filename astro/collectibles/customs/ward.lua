Astro.Collectible.WARD = Isaac.GetItemIdByName("Ward")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.WARD,
                "와드",
                "...",
                "사용 시 주변 3x3의 방을 보여줍니다."
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

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.WARD
)

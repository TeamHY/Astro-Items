local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.PINK_WARD = Isaac.GetItemIdByName("Pink Ward")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.PINK_WARD,
                "핑크 와드",
                "땅 밑도 보인다",
                "스테이지 중심 5x5의 방을 보여줍니다." ..
                "#{{ArrowGrayRight}} 중첩 시 범위가 증가합니다." ..
                "#숨어 있는 적을 아군으로 만듭니다."
            )
        end
    end
)

---@param range number
local function DisplayPinkWardRoom(range)
    local level = Game():GetLevel()

    for i = -range, range do
        for j = -range, range do
            local index = Astro:ConvertRoomPositionToIndex(Vector(i + 6, j + 6))

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
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.PINK_WARD) then
                DisplayPinkWardRoom(player:GetCollectibleNum(Astro.Collectible.PINK_WARD) * 2)
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
        if collectibleType == Astro.Collectible.PINK_WARD then
            DisplayPinkWardRoom(player:GetCollectibleNum(Astro.Collectible.PINK_WARD) * 2)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.PINK_WARD) then
                if entityNPC.Type == EntityType.ENTITY_NEEDLE or entityNPC.Type == EntityType.ENTITY_WIZOOB or entityNPC.Type == EntityType.ENTITY_RED_GHOST or entityNPC.Type == EntityType.ENTITY_POLTY then
                    entityNPC:AddEntityFlags(EntityFlag.FLAG_CHARM)
                    entityNPC:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
                end
            end

            break
        end
    end
)

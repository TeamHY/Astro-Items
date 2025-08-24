Astro.Trinket.BLOODY_BANDAGE = Isaac.GetTrinketIdByName("Bloody Bandage")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDTrinket(
                Astro.Trinket.BLOODY_BANDAGE,
                "피투성이 붕대", "이제 괜찮아...",
                "{{CursedRoom}} 저주방 입장/퇴장 시 피해를 입지 않습니다.",
                -- 황금
                "{{CursedRoom}} 맵에 저주방의 위치를 보여줍니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player ~= nil then
            if player:HasTrinket(Astro.Trinket.BLOODY_BANDAGE) then
                if damageFlags & DamageFlag.DAMAGE_CURSED_DOOR == DamageFlag.DAMAGE_CURSED_DOOR then
                    return false
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:GetTrinketMultiplier(Astro.Trinket.BLOODY_BANDAGE) > 1 then
            local level = Game():GetLevel()
            local idx = level:QueryRoomTypeIndex(RoomType.ROOM_CURSE, false, RNG())
            local room = level:GetRoomByIdx(idx)

            if room.Data.Type == RoomType.ROOM_CURSE then
                room.DisplayFlags = room.DisplayFlags | RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON
                level:UpdateVisibility()
            end
        end
    end
)

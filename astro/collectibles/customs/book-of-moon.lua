Astro.Collectible.BOOK_OF_MOON = Isaac.GetItemIdByName("Book of Moon")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BOOK_OF_MOON,
        "달의 서",
        "...",
        "사용 시 현재 방이 어두워지고 중앙에 달빛이 생깁니다. 스테이지당 한번 {{Card19}}XVIII - The Moon을 소환합니다." ..
        "#{{SecretRoom}}비밀방, {{SuperSecretRoom}}일급 비밀방, {{UltraSecretRoom}}특급 비밀방 최초 입장 시 중앙에 달빛이 생깁니다다."
    )
end

---@param player EntityPlayer
local function DarkenRoom(player)
    local level = Game():GetLevel()
    local currentRoomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
    
    currentRoomDesc.Flags = currentRoomDesc.Flags | RoomDescriptor.FLAG_PITCH_BLACK
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        Astro.Data["usedBookOfMoon"] = false
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
        DarkenRoom(player)

        Astro:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR, 1, Game():GetRoom():GetCenterPos())

        if not Astro.Data["usedBookOfMoon"] then
            Astro.Data["usedBookOfMoon"] = true
            Astro:SpawnCard(Card.CARD_MOON, player.Position)
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.BOOK_OF_MOON
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local room = Game():GetRoom()
        local roomType = room:GetType()
        
        if room:IsFirstVisit() then
            if Astro:HasCollectible(Astro.Collectible.BOOK_OF_MOON) then
                if roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET or roomType == RoomType.ROOM_ULTRASECRET then
                    Astro:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR, 1, Game():GetRoom():GetCenterPos())
                end
            end
        end
    end
)

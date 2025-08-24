Astro.Collectible.BOOK_OF_MOON = Isaac.GetItemIdByName("Book of Moon")
Astro.Collectible.BOOK_OF_LUNAR_ECLIPSE = Isaac.GetItemIdByName("Book of Lunar Eclipse")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BOOK_OF_MOON,
        "달의 서",
        "충전식 달빛",
        "사용 시;" ..
        "#{{ArrowGrayRight}} 그 방이 어두워지고 중앙에 달빛이 생기며;" ..
        "#{{ArrowGrayRight}} 스테이지당 한번 {{Card19}}XVIII - The Moon을 소환합니다." ..
        "#소지중일 때 {{SecretRoom}}비밀방, {{SuperSecretRoom}}일급비밀방, {{UltraSecretRoom}}특급비밀방 최초 입장 시 중앙에 달빛이 생깁니다." ..
        "#{{Collectible589}} {{ColorGray}}(달빛과 접촉 시 그 스테이지에서 {{HalfSoulHeart}}소울하트 +0.5, {{TearsSmall}}연사(+상한) +0.5){{CR}}"
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.BOOK_OF_LUNAR_ECLIPSE,
        "개기월식의 서",
        "붉게 뜬 달빛에 모습을 감추고서",
        "사용 시;" ..
        "#{{ArrowGrayRight}} 그 방이 어두워지고 중앙에 달빛이 생기며;" ..
        "#{{ArrowGrayRight}} 게임당 한번 {{Card19}}XVIII - The Moon?을 소환합니다." ..
        "#소지중일 때 {{TreasureRoom}}보물방, {{Shop}}상점, {{BossRoom}}보스방 최초 입장 시 중앙에 달빛이 생깁니다." ..
        "#{{Collectible589}} {{ColorGray}}(달빛과 접촉 시 그 스테이지에서 {{HalfSoulHeart}}소울하트 +0.5, {{TearsSmall}}연사(+상한) +0.5){{CR}}"
    )
end

---@param player EntityPlayer
local function DarkenRoom(player)
    local level = Game():GetLevel()
    local currentRoomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
    
    currentRoomDesc.Flags = currentRoomDesc.Flags | RoomDescriptor.FLAG_PITCH_BLACK
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data["usedBookOfLunarEclipse"] = false
        end
    end
)

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

        if not Astro.Data["usedBookOfLunarEclipse"] then
            Astro.Data["usedBookOfLunarEclipse"] = true
            Astro:SpawnCard(Card.CARD_REVERSE_MOON, player.Position)
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.BOOK_OF_LUNAR_ECLIPSE
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

            if Astro:HasCollectible(Astro.Collectible.BOOK_OF_LUNAR_ECLIPSE) then
                if roomType == RoomType.ROOM_TREASURE or roomType == RoomType.ROOM_SHOP or roomType == RoomType.ROOM_BOSS then
                    Astro:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEAVEN_LIGHT_DOOR, 1, Game():GetRoom():GetCenterPos())
                end
            end
        end
    end
)

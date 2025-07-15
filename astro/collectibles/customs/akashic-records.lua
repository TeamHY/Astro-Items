---

-- 지금 모드 템은 Effects로 구현되어 있지 않아서 적용할 수 없습니다.
local BOOK_LIST = {
    -- CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK,
    CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS,
    CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS,
    -- CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
    CollectibleType.COLLECTIBLE_MONSTER_MANUAL,
    CollectibleType.COLLECTIBLE_SATANIC_BIBLE,
    CollectibleType.COLLECTIBLE_TELEPATHY_BOOK,
    CollectibleType.COLLECTIBLE_BIBLE,
    CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
    CollectibleType.COLLECTIBLE_BOOK_OF_SIN,
    CollectibleType.COLLECTIBLE_NECRONOMICON,
    CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD,
    CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES,
}

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.AKASHIC_RECORDS = Isaac.GetItemIdByName("Akashic Records")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.AKASHIC_RECORDS,
        "아카식 레코드",
        "초차원적 정보의 집합체",
        "책 종류 아이템 사용 시 일시적 효과가 계속 적용됩니다. AstroItems에 추가된 책은 적용되지 않습니다." ..
        "#중첩 시 {{Room}} 맵에 {{Library}}책방의 위치가 표시되고 {{Library}} 책방 입장 시 {{Card83}}Soul of Cain을 발동합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()

        if currentRoom:GetFrameCount() <= 0 and currentRoom:IsFirstVisit() and currentRoom:GetType() == RoomType.ROOM_LIBRARY then
            if Astro:GetCollectibleNum(Astro.Collectible.AKASHIC_RECORDS) > 1 then
                Isaac.GetPlayer():UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Astro:GetCollectibleNum(Astro.Collectible.AKASHIC_RECORDS) > 1 then
            Astro:DisplayRoom(RoomType.ROOM_LIBRARY)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:GetCollectibleNum(Astro.Collectible.AKASHIC_RECORDS) > 1 then
            Astro:DisplayRoom(RoomType.ROOM_LIBRARY)
        end
    end,
    Astro.Collectible.AKASHIC_RECORDS
)

if REPENTOGON then
    Astro:AddPriorityCallback(
        ModCallbacks.MC_PRE_PLAYER_UPDATE,
        CallbackPriority.LATE,
        function (_, player)
            if player:HasCollectible(Astro.Collectible.AKASHIC_RECORDS) then
                local data = Astro.SaveManager.GetRunSave(player)

                if data["akashicRecordsEffects"] and #data["akashicRecordsEffects"] > 0 then
                    local removeList = {}

                    for i, item in ipairs(data["akashicRecordsEffects"]) do
                        if not player:GetEffects():HasCollectibleEffect(item) then
                            player:AddCollectibleEffect(item, true)
                        end
                        
                        table.insert(removeList, i)
                    end

                    for _, index in ipairs(removeList) do
                        data["akashicRecordsEffects"][index] = nil
                    end
                end
            end
        end
    )

    Astro:AddPriorityCallback(
        ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED,
        CallbackPriority.LATE,
        ---@param player EntityPlayer
        ---@param itemConfigItem ItemConfigItem
        function (_, player, itemConfigItem)
            if player:HasCollectible(Astro.Collectible.AKASHIC_RECORDS) and Astro:Contain(BOOK_LIST, itemConfigItem.ID) then
                local data = Astro.SaveManager.GetRunSave(player)

                if not data["akashicRecordsEffects"] then
                    data["akashicRecordsEffects"] = {}
                end

                table.insert(data["akashicRecordsEffects"], itemConfigItem.ID)
            end
        end
    )
end

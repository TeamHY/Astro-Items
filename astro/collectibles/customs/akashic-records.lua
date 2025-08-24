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

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.AKASHIC_RECORDS,
                "아카식 레코드",
                "초차원적 정보의 집합체",
                "책 종류 아이템 사용 시 그 책의 일시적 효과가 영구적으로 유지됩니다. {{ColorGray}}(AstroItems에 추가된 책은 미적용){{CR}}",
                -- 중첩 시
                "맵에 {{Library}}책방의 위치가 표시되며;" ..
                "#{{ArrowGrayRight}] 책방 입장 시 {{Card83}}Soul of Cain을 발동합니다."
            )
        end
    end
)

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
    Astro:AddCallback(
        ModCallbacks.MC_USE_ITEM,
        ---@param collectibleID CollectibleType
        ---@param rngObj RNG
        ---@param player EntityPlayer
        ---@param useFlags UseFlag
        ---@param activeSlot ActiveSlot
        ---@param varData integer
        function(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
            if player:HasCollectible(Astro.Collectible.AKASHIC_RECORDS) and Astro:Contain(BOOK_LIST, collectibleID) then
                Astro:RegisterPersistentPlayerEffect(
                    player,
                    function()
                        return player:HasCollectible(Astro.Collectible.AKASHIC_RECORDS)
                    end,
                    {
                        type = "collectible",
                        id = collectibleID
                    }
                )
            end
        end
    )
end

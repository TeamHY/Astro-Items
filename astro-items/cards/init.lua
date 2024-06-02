AstroItems.Card = {}

require "astro-items.cards.capsules"

AstroItems.Card.THE_COLD = Isaac.GetCardIdByName("I - The Cold")
AstroItems.Card.THE_SERVANT = Isaac.GetCardIdByName("II - The Servant")
AstroItems.Card.WISDOM = Isaac.GetCardIdByName("III - Wisdom")
AstroItems.Card.REPENTANCE = Isaac.GetCardIdByName("IV - Repentance")
AstroItems.Card.ETERNITY = Isaac.GetCardIdByName("V - Eternity")
AstroItems.Card.CORRUPTION = Isaac.GetCardIdByName("VI - Corruption")
AstroItems.Card.IMMOLATION = Isaac.GetCardIdByName("VII - Immolation")
AstroItems.Card.WORSHIP = Isaac.GetCardIdByName("VIII - Worship")

if EID then
    EID:addCard(AstroItems.Card.THE_COLD, "사용 시 모든 적이 둔화됩니다.", "I - The Cold")
    EID:addCard(AstroItems.Card.THE_SERVANT, "사용 시 랜덤한 패밀리어 한마리가 소환됩니다.", "II - The Servant")
    EID:addCard(AstroItems.Card.WISDOM, "사용 시 일급 비밀방으로 이동합니다.", "III - Wisdom")
    EID:addCard(AstroItems.Card.REPENTANCE, "사용 시 30% 확률로 해당 방 안의 아이템을 변경합니다.#실패 시 깨진 하트 2개를 추가합니다.#!!! {{LuckSmall}}행운 수치 비례: 행운 70 이상일 때 100% 확률 (행운 1당 +1%p)", "IV - Repentance")
    EID:addCard(AstroItems.Card.ETERNITY, "사용 시 이터널 하트가 1~4개 소환됩니다.", "V - Eternity")
    EID:addCard(AstroItems.Card.CORRUPTION, "사용 시 30% 확률로 에러방으로 이동합니다.#실패 시 깨진 하트 2개를 추가합니다.#!!! {{LuckSmall}}행운 수치 비례: 행운 70 이상일 때 100% 확률 (행운 1당 +1%p)", "VI - Corruption")
    EID:addCard(AstroItems.Card.IMMOLATION, "사용 시 희생방으로 이동합니다.", "VII - Immolation")
    EID:addCard(AstroItems.Card.WORSHIP, "사용 시 30% 확률로 현재 방 배열 아이템이 소환됩니다.#실패 시 배드 트립 알약을 1회 적용시킵니다.#!!! {{LuckSmall}}행운 수치 비례: 행운 70 이상일 때 100% 확률 (행운 1당 +1%p)", "VIII - Worship")
end

AstroItems:AddCallback(
    ModCallbacks.MC_USE_CARD,
    ---@param cardID Card
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    function(_, cardID, playerWhoUsedItem, useFlags)
        if cardID == AstroItems.Card.THE_COLD then
            playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_HOURGLASS, false, true, false, false)
            playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_HOURGLASS, false, true, false, false)
            playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_HOURGLASS, false, true, false, false)
        elseif cardID == AstroItems.Card.THE_SERVANT then
            playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_MONSTER_MANUAL, false, true, false, false)
        elseif cardID == AstroItems.Card.WISDOM then
            local level = Game():GetLevel()
            local roomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_SUPERSECRET, false, RNG());

            Game():StartRoomTransition(roomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
        elseif cardID == AstroItems.Card.REPENTANCE then
            local rng = playerWhoUsedItem:GetCardRNG(cardID)

            if rng:RandomFloat() < 0.3 + playerWhoUsedItem.Luck / 100 then
                playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_D6, false, true, false, false)
            else
                playerWhoUsedItem:AddBrokenHearts(2)
            end
        elseif cardID == AstroItems.Card.ETERNITY then
            local rng = playerWhoUsedItem:GetCardRNG(cardID)
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            for _ = 0, rng:RandomInt(4) do
                Isaac.Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_HEART,
                    HeartSubType.HEART_ETERNAL,
                    currentRoom:FindFreePickupSpawnPosition(playerWhoUsedItem.Position, 40, true),
                    Vector.Zero,
                    nil
                )
            end
        elseif cardID == AstroItems.Card.CORRUPTION then
            local rng = playerWhoUsedItem:GetCardRNG(cardID)

            if rng:RandomFloat() < 0.3 + playerWhoUsedItem.Luck / 100 then
                local level = Game():GetLevel()
                local roomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_ERROR, false, RNG());

                Game():StartRoomTransition(roomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
            else
                playerWhoUsedItem:AddBrokenHearts(2)
            end
        elseif cardID == AstroItems.Card.IMMOLATION then
            local level = Game():GetLevel()
            local roomIndex = level:QueryRoomTypeIndex(RoomType.ROOM_SACRIFICE, false, RNG());

            Game():StartRoomTransition(roomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
        elseif cardID == AstroItems.Card.WORSHIP then
            local rng = playerWhoUsedItem:GetCardRNG(cardID)

            if rng:RandomFloat() < 0.3 + playerWhoUsedItem.Luck / 100 then
                AstroItems:SpawnCollectible(CollectibleType.COLLECTIBLE_NULL, playerWhoUsedItem.Position)
            else
                playerWhoUsedItem:UsePill(PillEffect.PILLEFFECT_BAD_TRIP, PillColor.PILL_NULL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
        end
    end
)

---@param player EntityPlayer
---@param cardID Card
---@param slotId integer
local function WasteCard(player, cardID, slotId)
	player:SetCard(slotId, 0)
	player:UseCard(cardID)
end

---@param player EntityPlayer
function AstroItems:AutoWasting(player)
	if player:GetCard(0) == Card.RUNE_ANSUZ then
		WasteCard(player, Card.RUNE_ANSUZ, 0)
	elseif player:GetCard(0) == Card.CARD_WORLD then
		WasteCard(player, Card.CARD_WORLD, 0)
	elseif player:GetCard(0) == Card.CARD_SUN then
		WasteCard(player, Card.CARD_SUN, 0)
	elseif player:GetCard(0) == Card.CARD_JUSTICE then
		WasteCard(player, Card.CARD_JUSTICE, 0)
	elseif player:GetCard(0) == Card.CARD_HIEROPHANT then
		WasteCard(player, Card.CARD_HIEROPHANT, 0)
	elseif player:GetCard(0) == Card.CARD_REVERSE_HIEROPHANT then
		WasteCard(player, Card.CARD_REVERSE_HIEROPHANT, 0)
	elseif player:GetCard(0) == Card.CARD_RULES then
		WasteCard(player, Card.CARD_RULES, 0)
	elseif player:GetCard(0) == Card.CARD_ANCIENT_RECALL then
		WasteCard(player, Card.CARD_ANCIENT_RECALL, 0)
	elseif player:GetCard(0) == Card.CARD_REVERSE_MAGICIAN then
		WasteCard(player, Card.CARD_REVERSE_MAGICIAN, 0)
	elseif player:GetCard(0) == Card.RUNE_BERKANO then
		WasteCard(player, Card.RUNE_BERKANO, 0)
	elseif player:GetCard(0) == AstroItems.Card.ETERNITY then
		WasteCard(player, AstroItems.Card.ETERNITY, 0)
	elseif player:GetCard(0) == Card.CARD_HOLY and player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) then
		player:SetCard(0, 0) -- 획득 시 삭제
	else
		local pillColor = player:GetPill(0)

		if pillColor then
			local itemPool = Game():GetItemPool()
			local pillEffect = itemPool:GetPillEffect(pillColor)

			if pillEffect == PillEffect.PILLEFFECT_BALLS_OF_STEEL then
				player:SetPill(0, PillColor.PILL_NULL)
				player:UsePill(PillEffect.PILLEFFECT_BALLS_OF_STEEL, pillColor)
			end
		end
	end
end

AstroItems:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, AstroItems.AutoWasting)

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.AKASHIC_RECORDS = Isaac.GetItemIdByName("Akashic Records")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.AKASHIC_RECORDS,
        "아카식 레코드",
        "...",
        "맵에 {{Library}}책방의 위치가 표시됩니다."
        .."#{{Library}}책방 입장 시 모든 방이 밝혀집니다."
        .."#방 입장 시 10%의 확률로 {{Collectible58}}Book of Shadows, {{Collectible192}}Telepathy For Dummies, {{Collectible34}}The Book of Belial 중 하나가 발동합니다."
        .."#!!! {{LuckSmall}}행운 수치 비례: 행운 18 이상일 때 100% 확률 ({{LuckSmall}}행운 1당 +5%p)"
        .."#!!! 처음 획득 시 3개를 획득합니다."
    )
end

local baseChance = 0.1

local bookItems = {
    CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK,
    CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS,
    CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS,
    CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
    CollectibleType.COLLECTIBLE_HOW_TO_JUMP,
    CollectibleType.COLLECTIBLE_MONSTER_MANUAL,
    CollectibleType.COLLECTIBLE_SATANIC_BIBLE,
    CollectibleType.COLLECTIBLE_TELEPATHY_BOOK,
    CollectibleType.COLLECTIBLE_BIBLE,
    CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
    CollectibleType.COLLECTIBLE_BOOK_OF_SIN,
    CollectibleType.COLLECTIBLE_NECRONOMICON,
    CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD,
    CollectibleType.COLLECTIBLE_LEMEGETON,
    CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES,
}

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.RunAkashicRecords then
            local player = Isaac.GetPlayer()
            local rng = player:GetCollectibleRNG(AstroItems.Collectible.AKASHIC_RECORDS)
            local book = AstroItems:GetRandomCollectibles(bookItems, rng, 1)[1]

            AstroItems:SpawnCollectible(book, player.Position)

            AstroItems.Data.RunAkashicRecords = false
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        if AstroItems:HasCollectible(AstroItems.Collectible.AKASHIC_RECORDS) then
            AstroItems:DisplayRoom(RoomType.ROOM_LIBRARY)
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local room = Game():GetRoom()

        if room:GetType() == RoomType.ROOM_LIBRARY and AstroItems:HasCollectible(AstroItems.Collectible.AKASHIC_RECORDS) then
            Isaac.GetPlayer():UseCard(Card.RUNE_ANSUZ, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end

        if not room:IsClear() then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(AstroItems.Collectible.AKASHIC_RECORDS) then
                    local rng = player:GetCollectibleRNG(AstroItems.Collectible.AKASHIC_RECORDS)
                    
                    if rng:RandomFloat() < baseChance + player.Luck / 20 then
                        local random = rng:RandomInt(3)

                        if random == 0 then
                            player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)
                        elseif random == 1 then
                            player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK, false)
                        else
                            player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, false)
                        end
                    end
                end
            end
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        AstroItems.Data.RunAkashicRecords = true
        AstroItems:DisplayRoom(RoomType.ROOM_LIBRARY)

        if AstroItems:IsFirstAdded(AstroItems.Collectible.AKASHIC_RECORDS) then
            player:AddCollectible(AstroItems.Collectible.AKASHIC_RECORDS)
            player:AddCollectible(AstroItems.Collectible.AKASHIC_RECORDS)
        end
    end,
    AstroItems.Collectible.AKASHIC_RECORDS
)

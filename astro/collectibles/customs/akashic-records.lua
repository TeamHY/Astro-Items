---
local SOUND_VOLUME = 0.7
---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.AKASHIC_RECORDS = Isaac.GetItemIdByName("Akashic Records")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.AKASHIC_RECORDS,
        "아카식 레코드",
        "초차원적 정보의 집합체",
        "{{Room}} 맵에 {{Library}}책방의 위치가 표시됩니다."
        .."#{{Library}} 책방 입장 시 {{Card81}}Soul of Isaac, {{Card83}}Soul of Cain을 발동합니다."
        .."#방 입장, 방에서 몬스터를 처음 처치, 방 클리어 시 무작위의 책 종류 아이템이 발동됩니다."
    )
end

local bookItems = {
    CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK,
    CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS,
    CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS,
    CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
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

---@param player EntityPlayer
local function RunEffect(player)
    local rng = player:GetCollectibleRNG(Astro.Collectible.AKASHIC_RECORDS)
    
    local item = bookItems[rng:RandomInt(#bookItems) + 1]

    player:AnimateCollectible(Astro.Collectible.AKASHIC_RECORDS, "HideItem")
    player:UseActiveItem(item, false)
    SFXManager():Play(SoundEffect.SOUND_DIVINE_INTERVENTION, SOUND_VOLUME)
end

local isFirstKill = true

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        isFirstKill = true

        if not Game():GetRoom():IsClear() then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(Astro.Collectible.AKASHIC_RECORDS) then
                    RunEffect(player)
                    break
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.AKASHIC_RECORDS) and isFirstKill and entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                RunEffect(player)
                isFirstKill = false
                break
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.AKASHIC_RECORDS) then
                RunEffect(player)
                break
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()

        if currentRoom:GetFrameCount() <= 0 and currentRoom:IsFirstVisit() and currentRoom:GetType() == RoomType.ROOM_LIBRARY then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
            
                if player:HasCollectible(Astro.Collectible.AKASHIC_RECORDS) then
                    for _ = 1, player:GetCollectibleNum(Astro.Collectible.AKASHIC_RECORDS) do
                        player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                        player:UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                    end
                end
            end
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.AKASHIC_RECORDS) then
            Astro:DisplayRoom(RoomType.ROOM_LIBRARY)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        Astro:DisplayRoom(RoomType.ROOM_LIBRARY)
    end,
    Astro.Collectible.AKASHIC_RECORDS
)

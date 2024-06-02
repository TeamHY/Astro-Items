local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.PISCES_EX = Isaac.GetItemIdByName("Pisces EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.PISCES_EX,
        "초 물고기자리",
        "...",
        "게임 시간 2분마다 {{Card57}}The Magician?가 발동됩니다.#중첩 시 발동 간격이 줄어듭니다.#다음 게임 시작 시 {{Card57}}The Magician?을 하나 소환합니다.#중첩이 가능합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(AstroItems.Collectible.PISCES_EX) then
            if Game():GetFrameCount() % math.floor(3600 / player:GetCollectibleNum(AstroItems.Collectible.PISCES_EX)) == 0 then
                player:UseCard(Card.CARD_REVERSE_MAGICIAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.PiscesEXCount ~= nil and AstroItems.Data.PiscesEXCount > 0 then
            local player = Isaac.GetPlayer()
            local currentRoom = Game():GetLevel():GetCurrentRoom()

            for _ = 1, AstroItems.Data.PiscesEXCount do
                Isaac.Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TAROTCARD,
                    Card.CARD_REVERSE_MAGICIAN,
                    currentRoom:FindFreePickupSpawnPosition(player.Position, 40, true),
                    Vector.Zero,
                    nil
                )
            end

            AstroItems.Data.PiscesEXCount = 0
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        AstroItems.Data.PiscesEXCount = player:GetCollectibleNum(AstroItems.Collectible.PISCES_EX)
    end,
    AstroItems.Collectible.PISCES_EX
)

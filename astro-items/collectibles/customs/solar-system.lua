local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.SOLAR_SYSTEM = Isaac.GetItemIdByName("Solar System")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.SOLAR_SYSTEM,
        "태양계",
        "...",
        "획득 시 소지 중인 {{Planetarium}}천체관 아이템이 모두 제거됩니다. 제거한 수 만큼 {{Planetarium}}천체관 아이템을 소환합니다."
    )
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.SOLAR_SYSTEM) then
            -- 천체관 아이템 리스트 (itempools.xml과 별도로 업데이트해야 합니다.)
            local planetariumList = {
                392,
                588,
                589,
                590,
                591,
                592,
                595,
                596,
                597,
                598,
                AstroItems.Collectible.CYGNUS,
                AstroItems.Collectible.LIBRA_EX,
                AstroItems.Collectible.CANCER_EX,
                AstroItems.Collectible.SCORPIO_EX,
                AstroItems.Collectible.CAPRICORN_EX,
                AstroItems.Collectible.VIRGO_EX,
                AstroItems.Collectible.LEO_EX,
                AstroItems.Collectible.ARIES_EX,
                AstroItems.Collectible.TAURUS_EX,
                AstroItems.Collectible.AQUARIUS_EX,
                AstroItems.Collectible.CASIOPEA,
                AstroItems.Collectible.CORVUS,
                AstroItems.Collectible.PAVO,
                AstroItems.Collectible.COMET,
                AstroItems.Collectible.PISCES_EX,
                AstroItems.Collectible.GEMINI_EX,
                AstroItems.Collectible.PTOLEMAEUS,
                AstroItems.Collectible.ALTAIR,
                AstroItems.Collectible.VEGA,
                AstroItems.Collectible.LANIAKEA_SUPERCLUSTER,
                AstroItems.Collectible.SAGITTARIUS_EX,
                AstroItems.Collectible.SOLAR_SYSTEM,
            }

            local count = 0

            for _, value in ipairs(planetariumList) do
                if player:HasCollectible(value) then
                    count = count + AstroItems:RemoveAllCollectible(player, value)
                end
            end

            local list =
                AstroItems:GetRandomCollectibles(
                planetariumList,
                player:GetCollectibleRNG(AstroItems.Collectible.SOLAR_SYSTEM),
                count
            )

            for _, value in ipairs(list) do
                AstroItems:SpawnCollectible(value, player.Position)
            end
        end
    end,
    AstroItems.Collectible.SOLAR_SYSTEM
)

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function(_)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()
        local currentRoomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())

        if currentRoom:GetType() == RoomType.ROOM_ERROR and currentRoomDesc.Data.Variant == 0 then
            Isaac.Spawn(
                EntityType.ENTITY_PICKUP,
                PickupVariant.PICKUP_BIGCHEST,
                0,
                currentRoom:GetCenterPos(),
                Vector(0, 0),
                nil
            )
        end
    end
)

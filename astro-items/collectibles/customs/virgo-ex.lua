local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.VIRGO_EX = Isaac.GetItemIdByName("Virgo EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.VIRGO_EX,
        "초 처녀자리",
        "...",
        "획득 시 {{Trinket152}}Telescope Lens, {{Pill1}}Gulp!가 소환됩니다.#{{Planetarium}}천체관을 보여줍니다.#다음 게임 시작 시 {{Trinket152}}Telescope Lens 또는 {{Collectible194}}Magic 8 Ball 하나 소환합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.RunVirgo then
            local player = Isaac.GetPlayer()
            local collectibleRNG = player:GetCollectibleRNG(AstroItems.Collectible.VIRGO_EX)
            local position = Game():GetRoom():GetCenterPos()

            if collectibleRNG:RandomFloat() > 0.5 then
                AstroItems:SpawnTrinket(TrinketType.TRINKET_TELESCOPE_LENS, position)
            else
                AstroItems:SpawnCollectible(CollectibleType.COLLECTIBLE_MAGIC_8_BALL, position)
            end

            AstroItems.Data.RunVirgo = false
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if AstroItems:HasCollectible(AstroItems.Collectible.VIRGO_EX) then
            AstroItems:DisplayRoom(RoomType.ROOM_PLANETARIUM)
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.VIRGO_EX) then
            AstroItems:SpawnPill(PillEffect.PILLEFFECT_GULP, player.Position)
            AstroItems:SpawnTrinket(TrinketType.TRINKET_TELESCOPE_LENS, player.Position)
        end

        AstroItems:DisplayRoom(RoomType.ROOM_PLANETARIUM)

        AstroItems.Data.RunVirgo = true
    end,
    AstroItems.Collectible.VIRGO_EX
)

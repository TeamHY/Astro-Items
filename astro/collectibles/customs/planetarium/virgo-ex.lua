local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.VIRGO_EX = Isaac.GetItemIdByName("Virgo EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.VIRGO_EX,
        "초 처녀자리",
        "...",
        "획득 시 {{Trinket152}}Telescope Lens, {{Pill1}}Gulp!가 소환됩니다.#{{Room}} 맵에 {{Planetarium}}천체관이 표시됩니다.#다음 게임에서 {{Trinket152}}Telescope Lens 또는 {{Collectible194}}Magic 8 Ball을 소환합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.RunVirgo then
            local player = Isaac.GetPlayer()
            local collectibleRNG = player:GetCollectibleRNG(Astro.Collectible.VIRGO_EX)
            local position = Game():GetRoom():GetCenterPos()

            if collectibleRNG:RandomFloat() > 0.5 then
                Astro:SpawnTrinket(TrinketType.TRINKET_TELESCOPE_LENS, position)
            else
                Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_MAGIC_8_BALL, position)
            end

            Astro.Data.RunVirgo = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.VIRGO_EX) then
            Astro:DisplayRoom(RoomType.ROOM_PLANETARIUM)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.VIRGO_EX) then
            Astro:SpawnPill(PillEffect.PILLEFFECT_GULP, player.Position)
            Astro:SpawnTrinket(TrinketType.TRINKET_TELESCOPE_LENS, player.Position)
        end

        Astro:DisplayRoom(RoomType.ROOM_PLANETARIUM)

        Astro.Data.RunVirgo = true
    end,
    Astro.Collectible.VIRGO_EX
)

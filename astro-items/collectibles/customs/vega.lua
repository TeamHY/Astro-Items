local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.VEGA = Isaac.GetItemIdByName("Vega")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.VEGA,
        "베가",
        "...",
        "획득 시 {{Collectible534}}Schoolbag, {{Collectible458}}Belly Button, {{Collectible454}}Polydactyly를 소환합니다. 하나를 선택하면 나머지는 사라집니다.#다음 게임 시작 시 {{Card36}}Rune of Ansuz를 하나 소환합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.RunVega then
            local player = Isaac.GetPlayer()

            AstroItems:SpawnCard(Card.RUNE_ANSUZ, player.Position)

            AstroItems.Data.RunVega = false
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.VEGA) then
            AstroItems:SpawnCollectible(
                CollectibleType.COLLECTIBLE_SCHOOLBAG,
                player.Position + Vector(40 * -2, -40),
                AstroItems.Collectible.VEGA
            )
            AstroItems:SpawnCollectible(
                CollectibleType.COLLECTIBLE_BELLY_BUTTON,
                player.Position + Vector(40 * -2, -40),
                AstroItems.Collectible.VEGA
            )
            AstroItems:SpawnCollectible(
                CollectibleType.COLLECTIBLE_POLYDACTYLY,
                player.Position + Vector(40 * -2, -40),
                AstroItems.Collectible.VEGA
            )
        end

        AstroItems.Data.RunVega = true
    end,
    AstroItems.Collectible.VEGA
)

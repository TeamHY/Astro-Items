local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.RETROGRADE_ARCANA = Isaac.GetItemIdByName("Retrograde Arcana")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.RETROGRADE_ARCANA,
                "역행 아르카나",
                "...",
                "{{Card}}정방향 카드를 역방향 카드로 변경합니다.",
                "{{Collectible454}}Polydactyly 효과가 적용됩니다."
            )
        end
    end
)

local TAROT_TO_REVERSE_MAP = {
    [Card.CARD_FOOL] = Card.CARD_REVERSE_FOOL,
    [Card.CARD_MAGICIAN] = Card.CARD_REVERSE_MAGICIAN,
    [Card.CARD_HIGH_PRIESTESS] = Card.CARD_REVERSE_HIGH_PRIESTESS,
    [Card.CARD_EMPRESS] = Card.CARD_REVERSE_EMPRESS,
    [Card.CARD_EMPEROR] = Card.CARD_REVERSE_EMPEROR,
    [Card.CARD_HIEROPHANT] = Card.CARD_REVERSE_HIEROPHANT,
    [Card.CARD_LOVERS] = Card.CARD_REVERSE_LOVERS,
    [Card.CARD_CHARIOT] = Card.CARD_REVERSE_CHARIOT,
    [Card.CARD_JUSTICE] = Card.CARD_REVERSE_JUSTICE,
    [Card.CARD_HERMIT] = Card.CARD_REVERSE_HERMIT,
    [Card.CARD_WHEEL_OF_FORTUNE] = Card.CARD_REVERSE_WHEEL_OF_FORTUNE,
    [Card.CARD_STRENGTH] = Card.CARD_REVERSE_STRENGTH,
    [Card.CARD_HANGED_MAN] = Card.CARD_REVERSE_HANGED_MAN,
    [Card.CARD_DEATH] = Card.CARD_REVERSE_DEATH,
    [Card.CARD_TEMPERANCE] = Card.CARD_REVERSE_TEMPERANCE,
    [Card.CARD_DEVIL] = Card.CARD_REVERSE_DEVIL,
    [Card.CARD_TOWER] = Card.CARD_REVERSE_TOWER,
    [Card.CARD_STARS] = Card.CARD_REVERSE_STARS,
    [Card.CARD_MOON] = Card.CARD_REVERSE_MOON,
    [Card.CARD_SUN] = Card.CARD_REVERSE_SUN,
    [Card.CARD_JUDGEMENT] = Card.CARD_REVERSE_JUDGEMENT,
    [Card.CARD_WORLD] = Card.CARD_REVERSE_WORLD,
}

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:GetCollectibleNum(Astro.Collectible.RETROGRADE_ARCANA) >= 2 then
            if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_POLYDACTYLY, "AstroRetrogradeArcana") then
                hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_POLYDACTYLY, 0, 1, "AstroRetrogradeArcana")
            end
        end
    end,
    Astro.Collectible.RETROGRADE_ARCANA
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:GetCollectibleNum(Astro.Collectible.RETROGRADE_ARCANA) < 2 then
            if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_POLYDACTYLY, "AstroRetrogradeArcana") then
                hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_POLYDACTYLY, "AstroRetrogradeArcana")
            end
        end
    end,
    Astro.Collectible.RETROGRADE_ARCANA
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        local cardType = pickup.SubType

        if TAROT_TO_REVERSE_MAP[cardType] then
            if Astro:HasCollectible(Astro.Collectible.RETROGRADE_ARCANA) then
                pickup:Morph(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TAROTCARD,
                    TAROT_TO_REVERSE_MAP[cardType],
                    true,
                    true,
                    false
                )
            end
        end
    end,
    PickupVariant.PICKUP_TAROTCARD
)

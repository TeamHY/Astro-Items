local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.WITCHCRAFT = Isaac.GetItemIdByName("Witchcraft")

---@type table<integer, PlayerEffectInfo|PlayerEffectInfo[]>
CARD_LIST = CARD_LIST

local CARD_LIST = {
    [Card.CARD_MAGICIAN] = {
        type = "collectible",
        id = CollectibleType.COLLECTIBLE_TELEPATHY_BOOK,
    },
    [Card.CARD_EMPRESS] = {
        type = "collectible",
        id = CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON,
    },
    [Card.CARD_STRENGTH] = {
        type = "collectible",
        id = CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM,
    },
    [Card.CARD_HANGED_MAN] = {
        type = "collectible",
        id = CollectibleType.COLLECTIBLE_TRANSCENDENCE,
    },
    [Card.CARD_DEVIL] = {
        type = "collectible",
        id = CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
    },
    [Card.CARD_HUGE_GROWTH] = {
        {
            type = "null",
            id = NullItemID.ID_HUGE_GROWTH,
        },
        {
            type = "collectible",
            id = CollectibleType.COLLECTIBLE_LEO,
        }
    },
    [Card.CARD_REVERSE_EMPRESS] = {
        type = "null",
        id = NullItemID.ID_REVERSE_EMPRESS
    },
    [Card.CARD_REVERSE_DEVIL] = {
        {
            type = "null",
            id = NullItemID.ID_REVERSE_DEVIL,
        },
        {
            type = "collectible",
            id = CollectibleType.COLLECTIBLE_BIBLE,
        }
    }
}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.WITCHCRAFT,
                "위치크래프트",
                "마법 의뢰 받습니다",
                "!!! 획득 이후 {{Collectible451}}Tarot Cloth 미등장" ..
                "#{{Card}} 카드를 하나 드랍합니다." ..
                "#{{Collectible451}} 타로 타입 카드에 추가적인 효과를 부여하며;" ..
                "#{{ArrowGrayRight}} 일부 카드의 추가적인 효과는 {{Collectible286}}Blank Card로 사용 시 적용되지 않거나 약화됩니다." ..
                "#특정 카드 사용 시 카드의 일시적 효과가 영구적으로 유지됩니다.",
                -- 중첩 시
                "중첩 시 {{Collectible251}}Starter Deck 효과 적용"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                -- Witchcraft 소지 시 Tarot Cloth 등장 방지
                if Astro:HasCollectible(Astro.Collectible.WITCHCRAFT) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_TAROT_CLOTH,
                        modifierName = "Witchcraft"
                    }
                end
        
                return false
            end
        )
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_TAROT_CLOTH, "Witchcraft") then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_TAROT_CLOTH, 0, 1, "Witchcraft")
        end

        local witchcraftCount = player:GetCollectibleNum(Astro.Collectible.WITCHCRAFT)
        if witchcraftCount >= 2 and not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_STARTER_DECK, "Witchcraft") then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_STARTER_DECK, 0, 1, "Witchcraft")
        end
    end,
    Astro.Collectible.WITCHCRAFT
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local witchcraftCount = player:GetCollectibleNum(Astro.Collectible.WITCHCRAFT)
        
        if witchcraftCount == 0 then
            if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_TAROT_CLOTH, "Witchcraft") then
                hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_TAROT_CLOTH, "Witchcraft")
            end
        end

        if witchcraftCount < 2 and hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_STARTER_DECK, "Witchcraft") then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_STARTER_DECK, "Witchcraft")
        end
    end,
    Astro.Collectible.WITCHCRAFT
)

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_USE_CARD,
        ---@param cardID Card
        ---@param player EntityPlayer
        ---@param useFlags UseFlag
        function(_, cardID, player, useFlags)
            if player:HasCollectible(Astro.Collectible.WITCHCRAFT) then
                if CARD_LIST[cardID] then
                    if #CARD_LIST[cardID] > 0 then
                        for _, effect in ipairs(CARD_LIST[cardID]) do
                            Astro:RegisterPersistentPlayerEffect(player, function()
                                return player:HasCollectible(Astro.Collectible.WITCHCRAFT)
                            end, effect)
                        end
                    else
                        Astro:RegisterPersistentPlayerEffect(player, function()
                            return player:HasCollectible(Astro.Collectible.WITCHCRAFT)
                        end, CARD_LIST[cardID])
                    end
                end
            end
        end
    )
end

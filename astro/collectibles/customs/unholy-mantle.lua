local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.UNHOLY_MANTLE = Isaac.GetItemIdByName("Unholy Mantle")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.UNHOLY_MANTLE,
                "불경스런 망토",
                "타락한 방패",
                "!!! 획득 이후 {{Collectible313}}Holy Mantle 미등장" ..
                "#{{HolyMantleSmall}} 피격 시 방당 1회 한정으로 피해를 무시합니다." ..
                "#!!! 헌혈류 피격은 막아주지 않습니다."
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.UNHOLY_MANTLE) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_HOLY_MANTLE,
                        modifierName = "Unholy Mantle"
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
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_HOLY_MANTLE)
        end
    end,
    Astro.Collectible.UNHOLY_MANTLE
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_HOLY_MANTLE)
        end
    end,
    Astro.Collectible.UNHOLY_MANTLE
)

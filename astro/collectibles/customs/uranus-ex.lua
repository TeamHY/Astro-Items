local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.URANUS_EX = Isaac.GetItemIdByName("URANUS EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.URANUS_EX,
        "초 천왕성",
        "...",
        "{{Collectible596}}Uranus 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#{{Collectible530}}Death's List 효과가 적용됩니다."
    )
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_URANUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_URANUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_URANUS)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_DEATHS_LIST)
        end
    end,
    Astro.Collectible.URANUS_EX
)

-- Astro:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_URANUS) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_URANUS)
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_DEATHS_LIST)
--         end
--     end,
--     Astro.Collectible.URANUS_EX
-- )

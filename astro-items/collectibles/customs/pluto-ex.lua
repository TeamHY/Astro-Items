local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.PLUTO_EX = Isaac.GetItemIdByName("PLUTO EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.PLUTO_EX,
        "초 명왕성",
        "...",
        "{{Collectible597}}Pluto 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#방 입장 시 모든 적이 작아집니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.PLUTO_EX) then
                for _, entity in ipairs(Isaac.GetRoomEntities()) do
                    if entity:IsVulnerableEnemy() then
                        entity:AddShrink(EntityRef(player), 150)
                    end
                end

                break
            end
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_PLUTO)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_PLUTO) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_PLUTO)
        end
    end,
    AstroItems.Collectible.PLUTO_EX
)

-- AstroItems:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_PLUTO) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_PLUTO)
--         end
--     end,
--     AstroItems.Collectible.PLUTO_EX
-- )

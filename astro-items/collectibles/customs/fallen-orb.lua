local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.FALLEN_ORB = Isaac.GetItemIdByName("Fallen Orb")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.FALLEN_ORB, "타락한 오브", "불행한 운명", "{{Quality0}}/{{Quality1}}등급인 아이템이 등장하지 않습니다.")
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.FALLEN_ORB) then
                local itemPool = Game():GetItemPool()
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)

                local rng = RNG()
                rng:SetSeed(seed, 35)

                if itemConfigitem:HasTags(ItemConfig.TAG_QUEST) == false and selectedCollectible ~= CollectibleType.COLLECTIBLE_BREAKFAST and itemConfigitem.Quality <= 2 then
                    local newCollectable = itemPool:GetCollectible(itemPoolType, decrease, rng:Next())
                    print("Fallen Orb: " .. selectedCollectible .. " -> " .. newCollectable)

                    return newCollectable
                end
            end
        end
    end
)

-- AstroItems:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         local itemPool = Game():GetItemPool()

--         for _, config in ipairs(AstroItems.CollectableConfigs) do
--             if config.Quality == 0 or config.Quality == 1 then
--                 itemPool:RemoveCollectible(config.ID)
--             end
--         end
--     end,
--     AstroItems.Collectible.FALLEN_ORB
-- )

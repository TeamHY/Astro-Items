local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.FALLEN_ORB = Isaac.GetItemIdByName("Fallen Orb")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.FALLEN_ORB, "타락한 오브", "불행한 운명", "{{Quality0}}0등급/{{Quality1}}1등급 아이템 등장 시 리롤됩니다.#리롤된 아이템은 콘솔창에서 확인할 수 있습니다")
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.FALLEN_ORB) then
                local itemPool = Game():GetItemPool()
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)

                local rng = RNG()
                rng:SetSeed(seed, 35)

                if itemConfigitem:HasTags(ItemConfig.TAG_QUEST) == false and selectedCollectible ~= CollectibleType.COLLECTIBLE_BREAKFAST and itemConfigitem.Quality <= 1 then
                    local newCollectable = itemPool:GetCollectible(itemPoolType, decrease, rng:Next())
                    print("Fallen Orb: " .. selectedCollectible .. " -> " .. newCollectable)

                    return newCollectable
                end
            end
        end
    end
)

-- Astro:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         local itemPool = Game():GetItemPool()

--         for _, config in ipairs(Astro.CollectableConfigs) do
--             if config.Quality == 0 or config.Quality == 1 then
--                 itemPool:RemoveCollectible(config.ID)
--             end
--         end
--     end,
--     Astro.Collectible.FALLEN_ORB
-- )

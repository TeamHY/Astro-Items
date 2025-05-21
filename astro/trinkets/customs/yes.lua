Astro.Trinket.YES = Isaac.GetTrinketIdByName("Yes!")

if EID then
    EID:addTrinket(
        Astro.Trinket.YES,
        "패시브 아이템 등장 시 리롤됩니다.#리롤된 아이템은 콘솔창에서 확인할 수 있습니다",
        "좋아!"
    )

    Astro:AddGoldenTrinketDescription(Astro.Trinket.YES, "", 10)
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

            if player:HasTrinket(Astro.Trinket.YES) and not player:HasTrinket(TrinketType.TRINKET_NO) then
                local itemPool = Game():GetItemPool()
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)

                local rng = RNG()
                rng:SetSeed(seed, 35)

                if itemConfigitem:HasTags(ItemConfig.TAG_QUEST) == false and selectedCollectible ~= CollectibleType.COLLECTIBLE_BREAKFAST and itemConfigitem.Type ~= ItemType.ITEM_ACTIVE then
                    local newCollectable = itemPool:GetCollectible(itemPoolType, decrease, rng:Next())
                    print("Yes!: " .. selectedCollectible .. " -> " .. newCollectable)

                    return newCollectable
                end
            end
        end
    end
)

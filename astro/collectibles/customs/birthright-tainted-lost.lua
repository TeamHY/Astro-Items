local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_TAINTED_LOST = Isaac.GetItemIdByName("Birthright - Tainted Lost")

if EID then
    Astro:AddEIDCollectible(
    Astro.Collectible.BIRTHRIGHT_TAINTED_LOST,
    "알트 로스트의 생득권",
    "...",
    "offensive 태그 아이템 등장 시 리롤됩니다." ..
    "#리롤된 아이템은 콘솔창에서 확인할 수 있습니다")
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

            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST) then
                local itemPool = Game():GetItemPool()
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)

                local rng = RNG()
                rng:SetSeed(seed, 35)

                if not itemConfigitem:HasTags(ItemConfig.TAG_OFFENSIVE) and not itemConfigitem:HasTags(ItemConfig.TAG_QUEST) and selectedCollectible ~= CollectibleType.COLLECTIBLE_BREAKFAST then
                    local newCollectable = itemPool:GetCollectible(itemPoolType, decrease, rng:Next())
                    print("Birthright - Tainted Lost: " .. selectedCollectible .. " -> " .. newCollectable)

                    return newCollectable
                end
            end
        end
    end
)

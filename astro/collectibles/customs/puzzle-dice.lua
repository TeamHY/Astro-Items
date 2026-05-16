Astro.Collectible.PUZZLE_DICE = Isaac.GetItemIdByName("Puzzle Dice")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.PUZZLE_DICE,
                "퍼즐 주사위",
                "운명을 맞춰라",
                "사용 시 그 방의 아이템을 아무 세트에 포함된 아이템으로 바꿉니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.PUZZLE_DICE,
                "Puzzle Dice", "",
                "Rerolls room items to any transformation items",
                nil, "en_us"
            )
        end
    end
)

local TAG_LIST = {
    ItemConfig.TAG_SYRINGE,
    ItemConfig.TAG_MOM,
    ItemConfig.TAG_GUPPY,
    ItemConfig.TAG_FLY,
    ItemConfig.TAG_BOB,
    ItemConfig.TAG_MUSHROOM,
    ItemConfig.TAG_BABY,
    ItemConfig.TAG_ANGEL,
    ItemConfig.TAG_DEVIL,
    ItemConfig.TAG_POOP,
    ItemConfig.TAG_BOOK,
    ItemConfig.TAG_SPIDER,
}

Astro.ASTRO_SETS_LIST = {
    Astro.Collectible.CHUBBYS_HEAD,
    Astro.Collectible.SLEEPING_PUPPY,
    Astro.Collectible.CHUBBYS_TAIL,
    Astro.Collectible.REINCARNATION,
    Astro.Collectible.MATRYOSHKA,
    Astro.Collectible.SAMSARA,
}

local filteredCollectibles = {}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        local itemConfig = Isaac.GetItemConfig()

        local id = 1

        while true do
            local itemConfigItem = itemConfig:GetCollectible(id)

            if id > Astro.MAX_ORIGINAL_COLLECTIBLE_ID and itemConfigItem == nil then
                break
            end

            if itemConfigItem ~= nil then
                local isTagged = false
                local isAstroSet = false
        
                for _, tag in ipairs(TAG_LIST) do
                    if itemConfigItem:HasTags(tag) then
                        isTagged = true
                        break
                    end
                end
        
                for _, astroItem in ipairs(Astro.ASTRO_SETS_LIST) do
                    if itemConfigItem.ID == astroItem then
                        isAstroSet = true
                        break
                    end
                end

                if isTagged or isAstroSet then
                    table.insert(filteredCollectibles, itemConfigItem.ID)
                end
            end

            id = id + 1
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

        for _, entity in ipairs(items) do
            if entity.SubType ~= 0 and entity.SubType < 4294960000 then
                local item = entity:ToPickup()
                local nextid

                if item then
                    nextid = filteredCollectibles[rngObj:RandomInt(#filteredCollectibles) + 1]

                    Game():SpawnParticles(item.Position, EffectVariant.POOF01, 1, 0)
                    item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, nextid, true)
                    item.Touched = false
                end
            end
        end
        
        SFXManager():Play(910)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.PUZZLE_DICE
)

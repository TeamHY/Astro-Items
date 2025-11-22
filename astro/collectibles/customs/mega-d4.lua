---

Astro.Collectible.MEGA_D4 = Isaac.GetItemIdByName("Mega D4")

local ITEM_ID = Astro.Collectible.MEGA_D4

---

if EID then
    local rgonWarning = REPENTOGON and "" or "#!!! {{ColorError}}REPENTOGON이 없으면 작동하지 않습니다.#"
    local rgonWarningENG = REPENTOGON and "" or "#!!! {{ColorError}}Does not work without REPENTOGON.#"

    local CRAFT_HINT = {
        ["ko_kr"] = "#{{DiceRoom}} {{ColorYellow}}주사위방{{CR}}에서 사용하여 변환",
        ["en_us"] = "#{{DiceRoom}} Can be transformed {{ColorYellow}}using it in the Dice Room{{CR}}"
    }
    Astro:AddCraftHint(CollectibleType.COLLECTIBLE_D4, CRAFT_HINT)

    Astro:AddEIDCollectible(
        ITEM_ID,
        "대왕 4면체 주사위",
        "...",
        rgonWarning ..
        "{{Quality0}} 사용 시 등급을 선택하며;" ..
        "#{{ArrowGrayRight}} 소지중인 아이템 중 선택한 등급의 아이템을 그 방 배열의 아이템으로 바꿉니다."
    )

    Astro:AddEIDCollectible2(
        "en_us",
        ITEM_ID,
        "Mega D4",
        rgonWarningENG ..
        "On use, lets you choose a quality. Rerolls all items of the selected quality in your inventory into items from the current room's item pool."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectible CollectibleType
    ---@param rng RNG
    ---@param player EntityPlayer
    ---@param useFlags integer
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectible, rng, player, useFlags, activeSlot, varData)
        local room = Game():GetRoom()

        if room:GetType() == RoomType.ROOM_DICE and player:HasCollectible(CollectibleType.COLLECTIBLE_D4) then
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_D4)
            Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID, player.Position)
        end
    end,
    CollectibleType.COLLECTIBLE_D4
)

---@param quality integer
---@param player EntityPlayer
local function GetCollectibleToReroll(quality, player)
    local itemConfig = Isaac.GetItemConfig()
    local historyItems = player:GetHistory():GetCollectiblesHistory()

    local filteredItems = {}

    for _, item in ipairs(historyItems) do
        local itemConfigItem = itemConfig:GetCollectible(item:GetItemID())
        if itemConfigItem and itemConfigItem.Quality == quality and itemConfigItem.Type ~= ItemType.ITEM_ACTIVE and not itemConfigItem:HasTags(ItemConfig.TAG_QUEST) then
            table.insert(filteredItems, item:GetItemID())
        end
    end

    return filteredItems
end

---@param quality integer
---@param player EntityPlayer
local function GetCollectiblesWithQuality(quality, player)
    local itemPool = Game():GetItemPool()
    local rng = player:GetCollectibleRNG(ITEM_ID)

    local itemPoolType = itemPool:GetPoolForRoom(Game():GetRoom():GetType(), rng:GetSeed())

    if itemPoolType == ItemPoolType.POOL_NULL then
        itemPoolType = ItemPoolType.POOL_TREASURE
    end
            
    local roomItems = itemPool:GetCollectiblesFromPool(itemPoolType)

    local filteredItems = {}

    for _, item in ipairs(roomItems) do
        local itemConfigItem = Isaac.GetItemConfig():GetCollectible(item.itemID)
        if itemConfigItem and itemConfigItem.Quality == quality and itemConfigItem.Type ~= ItemType.ITEM_ACTIVE and not itemConfigItem.Hidden and not itemConfigItem:HasTags(ItemConfig.TAG_NO_EDEN) then
            table.insert(filteredItems, item.itemID)
        end
    end

    return filteredItems
end

local megaUI =
    Astro.MegaUI:CreateInstance(
    {
        anm2Path = "gfx/ui/mega-d4-ui.anm2",
        choiceCount = 5,
        itemId = ITEM_ID,
        onChoiceSelected = function(player, choice)
            local targetQuality = choice - 1
            local rng = player:GetCollectibleRNG(ITEM_ID)

            if not REPENTOGON then
                return
            end
            
            local itemsToReroll = GetCollectibleToReroll(targetQuality, player)
            local newItems = GetCollectiblesWithQuality(targetQuality, player)

            for _, item in ipairs(itemsToReroll) do
                if #newItems > 0 then
                    local targetIndex = rng:RandomInt(#newItems) + 1
                    local newItem = newItems[targetIndex]

                    player:RemoveCollectible(item)
                    player:AddCollectible(newItem)

                    table.remove(newItems, targetIndex)
                end
            end
        end
    }
)

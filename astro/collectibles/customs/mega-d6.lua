---

Astro.Collectible.MEGA_D6 = Isaac.GetItemIdByName("Mega D6")

local ITEM_ID = Astro.Collectible.MEGA_D6

---

if EID then
    local rgonWarning = REPENTOGON and "" or "#!!! {{ColorError}}REPENTOGON이 없으면 작동하지 않습니다.#"
    local rgonWarningENG = REPENTOGON and "" or "#!!! {{ColorError}}Does not work without REPENTOGON.#"

    local CRAFT_HINT = {
        ["ko_kr"] = "#{{DiceRoom}} {{ColorYellow}}주사위방{{CR}}에서 사용하여 변환",
        ["en_us"] = "#{{DiceRoom}} Can be transformed {{ColorYellow}}using it in the Dice Room{{CR}}"
    }
    Astro:AddCraftHint(CollectibleType.COLLECTIBLE_D6, CRAFT_HINT)

    Astro:AddEIDCollectible(
        ITEM_ID,
        "대왕 주사위",
        "굴려 굴려 굴려",
        rgonWarning ..
        "사용 시 그 방의 아이템에 {{ColorOrange}}아래 효과 중 하나를 골라{{CR}} 발동합니다:" ..
        "#{{ArrowGrayRight}} 다른 아이템으로 바꿉니다." ..
        "#{{ArrowGrayRight}} 같은 유형(패시브/액티브)의 다른 아이템으로 바꿉니다." ..
        "#{{ArrowGrayRight}} 같은 등급의 다른 아이템으로 바꿉니다." ..
        "#{{ArrowGrayRight}} {{Player31}}Tainted Lost에게 등장하지 않는 아이템으로 바꿉니다." ..
        "#{{ArrowGrayRight}} 랜덤 배열의 다른 아이템으로 바꾸며, 그 방의 픽업을 다른 픽업으로 바꿉니다."
    )

    Astro:AddEIDCollectible(
        ITEM_ID,
        "Mega D6",
        "",
        rgonWarningENG ..
        "When used, {{ColorOrange}}applies one of the following effects{{CR}} to all items in the room:" ..
        "#{{ArrowGrayRight}} Changes them to different items." ..
        "#{{ArrowGrayRight}} Preserves passive/active type and changes to different items." ..
        "#{{ArrowGrayRight}} Preserves quality and changes to different items." ..
        "#{{ArrowGrayRight}} Changes to useless items for {{Player31}}Tainted Lost." ..
        "#{{ArrowGrayRight}} Randomly changes all items regardless of pools. Also affects other pickups.",
        nil,
        "en_us"
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

        if room:GetType() == RoomType.ROOM_DICE and player:HasCollectible(CollectibleType.COLLECTIBLE_D6) then
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_D6)
            Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID, player.Position)
        end
    end,
    CollectibleType.COLLECTIBLE_D6
)

local megaUI =
    Astro.MegaUI:CreateInstance(
    {
        anm2Path = "gfx/ui/mega-d6-ui.anm2",
        choiceCount = 5,
        itemId = ITEM_ID,
        onChoiceSelected = function(player, choice)
            if choice == 1 then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, UseFlag.USE_NOANIM)
            elseif choice == 2 then
                if not REPENTOGON then
                    return
                end

                local findEntities =
                    Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true, false)
                local rng = player:GetCollectibleRNG(ITEM_ID)
                local itemPool = Game():GetItemPool()
                local itemPoolType = itemPool:GetPoolForRoom(Game():GetRoom():GetType(), rng:GetSeed())

                if itemPoolType == ItemPoolType.POOL_NULL then
                    itemPoolType = ItemPoolType.POOL_TREASURE
                end

                for _, entity in ipairs(findEntities) do
                    local pickup = entity:ToPickup() ---@cast pickup -nil

                    if pickup.SubType == 0 then
                        goto continue
                    end

                    local itemConfig = Isaac.GetItemConfig()
                    local itemConfigItem = itemConfig:GetCollectible(pickup.SubType)

                    if itemConfigItem.Type == ItemType.ITEM_ACTIVE then
                        local newItem =
                            itemPool:GetCollectible(
                            itemPoolType,
                            true,
                            rng:GetSeed(),
                            CollectibleType.COLLECTIBLE_BREAKFAST,
                            GetCollectibleFlag.BAN_PASSIVES
                        )
                        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem)
                    else
                        local newItem =
                            itemPool:GetCollectible(
                            itemPoolType,
                            true,
                            rng:GetSeed(),
                            CollectibleType.COLLECTIBLE_BREAKFAST,
                            GetCollectibleFlag.BAN_ACTIVES
                        )
                        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem)
                    end
                    ::continue::
                end
            elseif choice == 3 then
                if not REPENTOGON then
                    return
                end

                local findEntities =
                    Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true, false)
                local rng = player:GetCollectibleRNG(ITEM_ID)
                local itemPool = Game():GetItemPool()
                local itemPoolType = itemPool:GetPoolForRoom(Game():GetRoom():GetType(), rng:GetSeed())

                if itemPoolType == ItemPoolType.POOL_NULL then
                    itemPoolType = ItemPoolType.POOL_TREASURE
                end

                for _, entity in ipairs(findEntities) do
                    local pickup = entity:ToPickup() ---@cast pickup -nil

                    if pickup.SubType == 0 then
                        goto continue
                    end

                    local itemConfig = Isaac.GetItemConfig()
                    local itemConfigItem = itemConfig:GetCollectible(pickup.SubType)

                    if itemConfigItem and itemConfigItem.Quality >= 0 then
                        local targetQuality = itemConfigItem.Quality
                        local newItem = CollectibleType.COLLECTIBLE_BREAKFAST
                        local attempts = 0
                        local maxAttempts = 100

                        repeat
                            local seed = rng:RandomInt((2 ^ 32) - 1) + 1
                            local pickItem = itemPool:PickCollectible(itemPoolType, false, RNG(seed, 35)).itemID
                            local pickItemConfig = itemConfig:GetCollectible(pickItem)
                            attempts = attempts + 1

                            if pickItemConfig and pickItemConfig.Quality == targetQuality and pickItem ~= pickup.SubType then
                                newItem = itemPool:PickCollectible(itemPoolType, true, RNG(seed, 35)).itemID
                                break
                            end
                        until attempts >= maxAttempts

                        if attempts < maxAttempts then
                            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem)
                        else
                            pickup:Morph(
                                EntityType.ENTITY_PICKUP,
                                PickupVariant.PICKUP_COLLECTIBLE,
                                CollectibleType.COLLECTIBLE_BREAKFAST
                            )
                        end
                    end
                    ::continue::
                end
            elseif choice == 4 then
                if not REPENTOGON then
                    return
                end

                local findEntities =
                    Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true, false)
                local itemPool = Game():GetItemPool()
                local rng = player:GetCollectibleRNG(ITEM_ID)

                for _, entity in ipairs(findEntities) do
                    local pickup = entity:ToPickup() ---@cast pickup -nil
                    local validItems = {}

                    for _, itemConfig in ipairs(Astro.CollectableConfigs) do
                        if not itemConfig:HasTags(ItemConfig.TAG_OFFENSIVE) then
                            table.insert(validItems, itemConfig.ID)
                        end
                    end

                    local seed = rng:RandomInt((2 ^ 32) - 1) + 1
                    pickup:Morph(
                        EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_COLLECTIBLE,
                        itemPool:GetCollectibleFromList(validItems, seed, CollectibleType.COLLECTIBLE_BREAKFAST)
                    )
                end
            else
                player:UseCard(Card.CARD_SOUL_EDEN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
            SFXManager():Play(910)
        end
    }
)

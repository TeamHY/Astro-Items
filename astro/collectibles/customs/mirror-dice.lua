Astro.Collectible.MIRROR_DICE = Isaac.GetItemIdByName("Mirror Dice")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.MIRROR_DICE,
        "거울 주사위",
        "운명을 비춰라",
        "!!! 소지중인 아이템이 없을 경우 사용 불가" ..
        "#사용 시 그 방의 아이템을 소지중인 아이템 중 하나로 변경합니다."..
        "#{{ArrowGrayRight}} {{Quality0}}/{{Quality1}}등급 아이템은 등장하지 않습니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local inventory = Astro:getPlayerInventory(playerWhoUsedItem, false)

        -- 퀄리티가 2 이상인 아이템만 필터링
        local itemList = Astro:Filter(inventory, function(item)
            local itemConfig = Isaac.GetItemConfig():GetCollectible(item)
            return itemConfig and itemConfig.Quality > 1
        end)

        -- 가진 아이템이 필터링 된 결과에 아이템이 없을 경우 코드 조기 종료
        if #itemList == 0 then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local entities = Isaac.GetRoomEntities()
        local transformed = false

        for _, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local pickup = entity:ToPickup()
                
                if pickup.SubType ~= 0 then
                    local randomItems = Astro:GetRandomCollectibles(itemList, rngObj, 1, Astro.Collectible.MIRROR_DICE, true)

                    -- 변환 아이템이 없으면 코드 계속 진행
                    if not randomItems or #randomItems == 0 then
                        goto continue
                    end

                    -- 방에 있는 아이템을 필터링이 된 아이템중 하나로 변경
                    pickup:Morph(pickup.Type, pickup.Variant, randomItems[1], true)
                    Game():SpawnParticles(entity.Position, EffectVariant.POOF01, 1, 0)
                    SFXManager():Play(910)
                    transformed = true

                    ::continue::
                end
            end
        end

        -- 변환 발생시 쿨타임 초기화, 아닐시에는 초기화 없음.
        return {
            Discharge = transformed,
            Remove = false,
            ShowAnim = transformed,
        }
    end,
    Astro.Collectible.MIRROR_DICE
)

Astro.Collectible.GRADUATION_CERTIFICATE = Isaac.GetItemIdByName("Graduation Certificate")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.GRADUATION_CERTIFICATE,
                "졸업증명서",
                "안녕은 영원한 헤어짐은 아니겠지요",
                "사용 시 소지중인 아이템이 있는 방으로 이동합니다." ..
                "#{{ArrowGrayRight}} 아이템 하나 획득 시 원래 있던 장소로 돌아갑니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.GraduationCertificateUsed = false
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
        playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, UseFlag.USE_NOANIM, 0)

        Astro.Data.GraduationCertificateUsed = true
        Astro.Data.GraduationCertificateItems = {}

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local inventory = Astro:getPlayerInventory(player, false)

            for _, itemID in ipairs(inventory) do
                if itemID == Astro.Collectible.GRADUATION_CERTIFICATE then
                    goto continue
                end

                if Astro:Contain(Astro.Data.GraduationCertificateItems, itemID) then
                    goto continue
                end

                table.insert(Astro.Data.GraduationCertificateItems, itemID)
                ::continue::
            end
        end

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.GRADUATION_CERTIFICATE
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if not Astro.Data.GraduationCertificateUsed then
            return
        end

        local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

        table.sort(
        entities,
            function(a, b)
                if a.Position.Y == b.Position.Y then
                    return a.Position.X < b.Position.X
                end
                return a.Position.Y < b.Position.Y
            end
        )

        for _, entity in ipairs(entities) do
            local pickup = entity:ToPickup() ---@cast pickup -nil

            if #Astro.Data.GraduationCertificateItems == 0 then
                pickup:Remove()
                goto continue
            end

            local itemID = Astro.Data.GraduationCertificateItems[1]
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemID, true)
            table.remove(Astro.Data.GraduationCertificateItems, 1)
            ::continue::
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_ITEM_PICKUP,
    ---@param player EntityPlayer
    ---@param pickingUpItem { itemType: ItemType, subType: CollectibleType | TrinketType }
    function(_, player, pickingUpItem)
        if pickingUpItem.itemType ~= ItemType.ITEM_TRINKET then
            Astro.Data.GraduationCertificateUsed = false
        end
    end
)

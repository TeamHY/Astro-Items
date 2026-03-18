local isc = require("astro.lib.isaacscript-common")

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
                "#{{ArrowGrayRight}} 아이템 하나 획득 시 원래 있던 장소로 돌아갑니다." ..
                "!!! 아이템의 종류는 그 스테이지에서 처음 사용한 시점에 결정됨"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.GRADUATION_CERTIFICATE,
                "Graduation Certificate", "",
                "Teleports Isaac to a floor that contains items he holds in the run" ..
                "#Choosing an item from this floor teleports Isaac back to the room he came from" ..
                "!!! Items are assigned at the time they are first used in that floor",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.GraduationCertificateUsed = false
            Astro.Data.GraduationCertificateItems = {}
            Astro.Data.GraduationCertificateFloor = nil
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
        if collectibleID == Astro.Collectible.GRADUATION_CERTIFICATE then
            playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, UseFlag.USE_NOANIM, 0)

            Astro.Data.GraduationCertificateUsed = true
            Astro.Data.GraduationCertificateItems = Astro.Data.GraduationCertificateItems or {}

            local level = Game():GetLevel()
            local currentFloor = level:GetAbsoluteStage()
            
            if not Astro.Data.GraduationCertificateFloor or Astro.Data.GraduationCertificateFloor ~= currentFloor then
                Astro.Data.GraduationCertificateItems = {}
                local inventory = Astro:getPlayerInventory(playerWhoUsedItem, false)

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

            Astro.Data.GraduationCertificateFloor = currentFloor

            return {
                Discharge = true,
                Remove = true,
                ShowAnim = true,
            }
        elseif collectibleID == CollectibleType.COLLECTIBLE_FORGET_ME_NOW or collectibleID == CollectibleType.COLLECTIBLE_R_KEY then
            Astro.Data.GraduationCertificateUsed = false
            Astro.Data.GraduationCertificateItems = {}
            Astro.Data.GraduationCertificateFloor = nil
        end
    end
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

        local level = Game():GetLevel()
        local room = level:GetCurrentRoom()
        
        if room:IsFirstVisit() then
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
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.PRE_ITEM_PICKUP,
    ---@param player EntityPlayer
    ---@param pickingUpItem { itemType: ItemType, subType: CollectibleType | TrinketType }
    function(_, player, pickingUpItem)
        local level = Game():GetLevel()
        local roomDesc = level:GetCurrentRoomDesc()
        local currentDimension = Astro:GetDimension(roomDesc)

        if currentDimension == 2 and pickingUpItem.itemType ~= ItemType.ITEM_TRINKET then
            Astro.Data.GraduationCertificateUsed = false
        end
    end
)
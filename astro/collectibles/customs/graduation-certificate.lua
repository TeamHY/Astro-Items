Astro.Collectible.GRADUATION_CERTIFICATE = Isaac.GetItemIdByName("Graduation Certificate")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.GRADUATION_CERTIFICATE,
                "졸업증명서",
                "안녕은 영원한 헤어짐은 아니겠지요",
                "사용 시 그 방의 아이템을 소지중인 아이템으로 바꿉니다."
            )
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
        local inventory = Astro:getPlayerInventory(playerWhoUsedItem, false)
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType ~= 0 then
                local item = Astro:GetRandomCollectibles(inventory, rngObj, 1, Astro.Collectible.GRADUATION_CERTIFICATE)[1]

                entity:ToPickup():Morph(entity.Type, entity.Variant, item, true)
                Game():SpawnParticles(entity.Position, EffectVariant.POOF01, 1, 0)
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

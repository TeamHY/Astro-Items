Astro.Collectible.CASSANDRAS_CRYSTAL_BALL = Isaac.GetItemIdByName("Cassandra's Crystal Ball")

local ITEM_ID = Astro.Collectible.CASSANDRAS_CRYSTAL_BALL

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "카산드라의 수정 구슬",
                "믿지 못할 미래",
                "!!! 일회용 !!!" ..
                "#사용 시 그 방의 아이템을 업그레이드합니다."
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(ITEM_ID),
                { Astro.Players.STELLAR, Astro.Players.STELLAR_B },
                {
                    "!!! 일회용 !!!#사용 시",
                    "사용 시"
                },
                nil, "ko_kr", nil
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Cassandra's Crystal Ball", "",
                "!!! SINGLE USE !!!" ..
                "#Upgrades items in the room",
                nil, "en_us"
            )
            EID:addPlayerCondition(
                "5.100." .. tostring(ITEM_ID),
                { Astro.Players.STELLAR, Astro.Players.STELLAR_B },
                {
                    "!!! SINGLE USE !!!#Upgrades",
                    "Upgrades"
                },
                nil, "en_us", nil
            )

            EID:addDescriptionModifier(
                "Cassandra's Crystal Ball Modifier",
                function(descObj)
                    if descObj.ObjType ~= 5 or descObj.ObjVariant ~= 100 or not Astro.UPGRADE_LIST[descObj.ObjSubType] then
                        return false
                    end

                    for i = 0, Game():GetNumPlayers() - 1 do
                        local player = Isaac.GetPlayer(i)
                        if player:HasCollectible(ITEM_ID) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(ITEM_ID)]) then
                            return true
                        end
                    end
                end,
                function(descObj)
                    local id = Astro.UPGRADE_LIST[descObj.ObjSubType].Id
                    local newItemName = "{{Collectible" .. id .. "}} " .. EID:getObjectName(5, 100, id)
                    local text = EID:getLanguage() == "ko_kr" and ("{{ColorYellow}}" .. newItemName .. "{{CR}}" .. Astro:PickJosa(newItemName, "으로/로") .. " 변환") or ("Rerolls to {{ColorYellow}}" .. newItemName .. "{{CR}}")

                    EID:appendToDescription(descObj, "#{{Collectible" .. ITEM_ID .. "}} " .. text)
                    return descObj
                end
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
        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = entity:ToPickup()
            local upgrade = Astro.UPGRADE_LIST[pickup.SubType]

            if upgrade then
                pickup:Morph(pickup.Type, pickup.Variant, upgrade.Id, true)
                pickup.Touched = false
                Game():SpawnParticles(pickup.Position, EffectVariant.POOF01, 1, 0)
            end
        end

        local playerType = playerWhoUsedItem:GetPlayerType()

        return {
            Discharge = true,
            Remove = playerType ~= Astro.Players.STELLAR and playerType ~= Astro.Players.STELLAR_B,
            ShowAnim = true,
        }
    end,
    ITEM_ID
)

---

local USE_SOUND = Isaac.GetSoundIdByName("Specialsummon")

local USE_SOUND_VOLUME = 1 -- 0 ~ 1

---

Astro.Collectible.CURSE_OF_ARAMATIR = Isaac.GetItemIdByName("Curse of Aramatir")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.CURSE_OF_ARAMATIR,
                "금주 아라마티아",
                "리타마라",
                "!!! 일회용" ..
                "#사용 시 가장 가까운 패시브 아이템을 복사하여 획득합니다." ..
                "#!!! 방에 패시브 아이템이 없으면 사용 불가"
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.CURSE_OF_ARAMATIR),
                { Astro.Players.WATER_ENCHANTRESS, Astro.Players.WATER_ENCHANTRESS_B },
                {
                    "!!! 일회용",
                    "!!! {{Player" .. Astro.Players.WATER_ENCHANTRESS .. "}}¤/ {{Player" .. Astro.Players.WATER_ENCHANTRESS_B .. "}}: {{ColorIsaac}}스테이지 당 한번만{{CR}} 사용 가능"
                },
                nil, "ko_kr", nil
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if Astro:IsWaterEnchantress(player) then
                local data = Astro:GetPersistentPlayerData(player)

                data.curseOfAramatir = {
                    used = false
                }
            end
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
        local playerData = Astro:GetPersistentPlayerData(playerWhoUsedItem)
        local isHero = Astro:IsWaterEnchantress(playerWhoUsedItem)
        local itemConfig = Isaac.GetItemConfig()

        local closestConfig
        local closestDistance = math.huge

        if not (isHero and playerData.curseOfAramatir and playerData.curseOfAramatir.used) then
            for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                local config = entity.SubType > 0 and itemConfig:GetCollectible(entity.SubType)
                local distance = entity.Position:Distance(playerWhoUsedItem.Position)

                if config and config.Type ~= ItemType.ITEM_ACTIVE and distance < closestDistance then
                    closestConfig = config
                    closestDistance = distance
                end
            end
        end

        if not closestConfig then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        playerWhoUsedItem:AnimateCollectible(closestConfig.ID, "UseItem", "PlayerPickupSparkle")
        playerWhoUsedItem:QueueItem(closestConfig)

        SFXManager():Play(USE_SOUND, USE_SOUND_VOLUME)

        if isHero then
            playerData.curseOfAramatir = {
                used = true
            }
        end

        return {
            Discharge = true,
            Remove = not isHero,
            ShowAnim = false,
        }
    end,
    Astro.Collectible.CURSE_OF_ARAMATIR
)

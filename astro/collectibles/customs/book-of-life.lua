Astro.Collectible.BOOK_OF_LIFE = Isaac.GetItemIdByName("Book of Life")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            local rgon = REPENTOGON and "#↑ 소지중일 때 목숨 +1#{{ArrowGrayRight}} 사망 시 그 방에서 즉시 체력 0.5로 부활하며 이 아이템은 사라집니다." or ""
            local rgonEng = REPENTOGON and "#↑ +1 Life while held#{{ArrowGrayRight}} Revives with 0.5 health in the room on death; item disappears" or ""

            local astrobirthtext = Astro.IsFight and "#이번 게임의 금지 아이템 중 1개를 소환합니다." or "#사용 시 이번 게임에서 등장한 아이템 중 소지중이지 않은 아이템 1개를 소환합니다."
            local astrobirthtexteng = Astro.IsFight and "#Spawns one banned item from this run" or "#Spawns one non-held item from appeared items this run"

            Astro.EID:AddCollectible(
                Astro.Collectible.BOOK_OF_LIFE,
                "생자의 서",
                "금단의 주술",
                "!!! 일회용" ..
                rgon .. astrobirthtext
            )
            EID:addCarBatteryCondition(Astro.Collectible.BOOK_OF_LIFE, "1개 더 생성", nil, nil, "ko_kr")
            ----
            Astro.EID:AddCollectible(
                Astro.Collectible.BOOK_OF_LIFE,
                "Book of Life",
                "",
                "!!! Single use" ..
                rgonEng .. astrobirthtext,
                nil, "en_us"
            )
            EID:addCarBatteryCondition(Astro.Collectible.BOOK_OF_LIFE, "One more spawn", nil, nil, "en_us")
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.SeenItems = {}
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if not Astro.Data.SeenItems then
            Astro.Data.SeenItems = {}
        end

        if not Astro:Exists(Astro.Data.SeenItems, selectedCollectible) then
            table.insert(Astro.Data.SeenItems, selectedCollectible)
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
        local selectedCollectible ---@type CollectibleType
        local success = false
        local count = playerWhoUsedItem:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 2 or 1

        for i = 1, count do
            if Astro.IsFight then
                local banList = Astro.Data.currentBanItems

                selectedCollectible = Astro:GetRandomCollectibles(banList, rngObj, 1)[1]
            else
                local seenItems = Astro.Data.SeenItems
                local inventory = Astro:getPlayerInventory(playerWhoUsedItem, false)

                selectedCollectible = Astro:GetRandomCollectibles(seenItems, rngObj, 1, inventory)[1]
            end
            
            if selectedCollectible then
                Astro:SpawnCollectible(selectedCollectible, playerWhoUsedItem.Position)
                success = true
            end
        end

        if success then
            return {
                Discharge = true,
                Remove = true,
                ShowAnim = true,
            }
        end

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
    end,
    Astro.Collectible.BOOK_OF_LIFE
)

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH,
        function(_, player)
            if player:HasCollectible(Astro.Collectible.BOOK_OF_LIFE, true) then
                player:RemoveCollectible(Astro.Collectible.BOOK_OF_LIFE)
                player:SetMinDamageCooldown(120)
                return false
            end
        end
    )
end

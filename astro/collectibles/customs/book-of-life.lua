Astro.Collectible.BOOK_OF_LIFE = Isaac.GetItemIdByName("Book of Life")

if EID then
    local astrobirthtext
    if Astro.Fight then
        astrobirthtext = "이번 게임의 금지 아이템 중 하나를 소환합니다."
    else
        astrobirthtext = "사용 시 이번 게임에서 등장했던 아이템 중 소지 중이지 않은 아이템 하나를 소환합니다."
    end

    Astro:AddEIDCollectible(
        Astro.Collectible.BOOK_OF_LIFE,
        "생자의 서",
        "금단의 주술",
        "#!!! 일회용 아이템" ..
        "#" .. astrobirthtext ..
        "#소지 중 사망 시 그 방에서 부활하고 해당 아이템은 사라집니다."
    )
end

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

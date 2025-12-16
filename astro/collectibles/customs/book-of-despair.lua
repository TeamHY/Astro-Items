---

local PASSIVE_TEARS_INCREMENT = 0.5

local USE_TEARS_INCREMENT = 2.0

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BOOK_OF_DESPAIR = Isaac.GetItemIdByName("Book of Despair")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BOOK_OF_DESPAIR,
        "절망의 서",
        "일시적 공격 속도 증가",
        "{{TearsSmall}} 소지중일 때 연사 +0.5" ..
        "#{{Timer}} 사용 시 그 방에서 {{TearsSmall}}연사 +2"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            
            if player:HasCollectible(Astro.Collectible.BOOK_OF_DESPAIR) then
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
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
        local data = Astro.SaveManager.GetRoomSave(playerWhoUsedItem)

        if not data["bookOfDespairCount"] then
            data["bookOfDespairCount"] = 0
        end
    
        data["bookOfDespairCount"] = data["bookOfDespairCount"] + 1
        
        playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        playerWhoUsedItem:EvaluateItems()
        
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.BOOK_OF_DESPAIR
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.BOOK_OF_DESPAIR) then
            player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, PASSIVE_TEARS_INCREMENT)
        end
        
        local data = Astro.SaveManager.GetRoomSave(player)

        if data["bookOfDespairCount"] then
            player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, USE_TEARS_INCREMENT * data["bookOfDespairCount"])
        end
    end,
    CacheFlag.CACHE_FIREDELAY
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    function(_, player, collectibleType)
        if collectibleType == Astro.Collectible.BOOK_OF_DESPAIR then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    function(_, player, collectibleType)
        if collectibleType == Astro.Collectible.BOOK_OF_DESPAIR then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end
)

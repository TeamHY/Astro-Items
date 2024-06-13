local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.BIRTHRIGHT_JUDAS = Isaac.GetItemIdByName("Birthright - Judas")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.BIRTHRIGHT_JUDAS, "생득권 - 유다", "충전을 힘으로!", "액티브 아이템 사용 시 쿨타임 한칸당 +1(고정 공격력) 증가됩니다.#최대 5까지만 증가됩니다.#중첩 시 다음 증가량부터 적용됩니다.")
end

local damageIncrement = 1

local damageMaxinum = 5

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if isContinued then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(AstroItems.Collectible.BIRTHRIGHT_JUDAS) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        if playerWhoUsedItem:HasCollectible(AstroItems.Collectible.BIRTHRIGHT_JUDAS) then
            local data = AstroItems:GetPersistentPlayerData(playerWhoUsedItem)
            local maxCharges = Isaac.GetItemConfig():GetCollectible(collectibleID).MaxCharges

            if not data.birthrightJudasDamage then
                data.birthrightJudasDamage = 0
            end

            data.birthrightJudasDamage = data.birthrightJudasDamage + maxCharges * damageIncrement * playerWhoUsedItem:GetCollectibleNum(AstroItems.Collectible.BIRTHRIGHT_JUDAS)

            if data.birthrightJudasDamage > damageMaxinum then
                data.birthrightJudasDamage = damageMaxinum
            end

            playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            playerWhoUsedItem:EvaluateItems()
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.BIRTHRIGHT_JUDAS) then
                local data = AstroItems:GetPersistentPlayerData(player)
    
                data.birthrightJudasDamage = 0
                
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.BIRTHRIGHT_JUDAS) then
            local data = AstroItems:GetPersistentPlayerData(player)

            if data and data.birthrightJudasDamage then
                player.Damage = player.Damage + data.birthrightJudasDamage
            end
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

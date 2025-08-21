local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_JUDAS = Isaac.GetItemIdByName("Birthright - Judas")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BIRTHRIGHT_JUDAS,
        "유다의 생득권",
        "에너지가 힘이 되리라",
        "{{DamageSmall}} 액티브 아이템 사용 시 충전량 한칸당 공격력 +1 (최대 +5)" ..
        "#{{ArrowGrayRight}} 중첩 시 증가량과 최대치가 증가합니다."
    )
end

local damageIncrement = 1

local damageMaxinum = 5

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if isContinued then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_JUDAS) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
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
        if playerWhoUsedItem:HasCollectible(Astro.Collectible.BIRTHRIGHT_JUDAS) then
            local data = Astro:GetPersistentPlayerData(playerWhoUsedItem)
            local maxCharges = Isaac.GetItemConfig():GetCollectible(collectibleID).MaxCharges

            if not data.birthrightJudasDamage then
                data.birthrightJudasDamage = 0
            end

            data.birthrightJudasDamage = data.birthrightJudasDamage + maxCharges * damageIncrement * playerWhoUsedItem:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_JUDAS)

            local maxinum = damageMaxinum * playerWhoUsedItem:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_JUDAS)

            if data.birthrightJudasDamage > maxinum then
                data.birthrightJudasDamage = maxinum
            end

            playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            playerWhoUsedItem:EvaluateItems()
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_JUDAS) then
                local data = Astro:GetPersistentPlayerData(player)
    
                data.birthrightJudasDamage = 0
                
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_JUDAS) then
            local data = Astro:GetPersistentPlayerData(player)

            if data and data.birthrightJudasDamage then
                player.Damage = player.Damage + data.birthrightJudasDamage
            end
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

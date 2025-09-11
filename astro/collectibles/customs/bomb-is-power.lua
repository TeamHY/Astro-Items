local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BOMB_IS_POWER = Isaac.GetItemIdByName("Bomb Is Power")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BOMB_IS_POWER,
        "폭탄 = 힘",
        "펑펑펑 = 공격력",
        "{{DamageSmall}} 폭탄 1개당 공격력 +0.16",
        "(중첩 가능)"
    )
end

local BOMB_IS_POWER_INCREMENT = 0.16

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.BOMB_IS_POWER) then
            local data = player:GetData()

            if data.BombIsPower == nil then
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()

                data.BombIsPower = {
                    Bomb = player:GetNumBombs()
                }
            else
                local numBombs = player:GetNumBombs()

                if data.BombIsPower.Bomb ~= numBombs then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()

                    data.BombIsPower.Bomb = numBombs
                end
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end,
    Astro.Collectible.BOMB_IS_POWER
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.BOMB_IS_POWER) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + player:GetNumBombs() * player:GetCollectibleNum(Astro.Collectible.BOMB_IS_POWER) * BOMB_IS_POWER_INCREMENT
            end
        end
    end
)

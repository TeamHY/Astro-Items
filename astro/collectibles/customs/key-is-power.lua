local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.KEY_IS_POWER = Isaac.GetItemIdByName("Key Is Power")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.KEY_IS_POWER, "열쇠 = 힘", "...", "열쇠 1개당 {{DamageSmall}}공격력(고정) +0.16")
end

local KEY_IS_POWER_INCREMENT = 0.16

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.KEY_IS_POWER) then
            local data = player:GetData()

            if data.KeyIsPower == nil then
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()

                data.KeyIsPower = {
                    Key = player:GetNumKeys()
                }
            else
                local numKeys = player:GetNumKeys()

                if data.KeyIsPower.Key ~= numKeys then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()

                    data.KeyIsPower.Key = numKeys
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
    Astro.Collectible.KEY_IS_POWER
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.KEY_IS_POWER) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + player:GetNumKeys() * player:GetCollectibleNum(Astro.Collectible.KEY_IS_POWER) * KEY_IS_POWER_INCREMENT
            end
        end
    end
)

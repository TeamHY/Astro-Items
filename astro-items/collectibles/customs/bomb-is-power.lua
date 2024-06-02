local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.BOMB_IS_POWER = Isaac.GetItemIdByName("Bomb Is Power")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.BOMB_IS_POWER, "폭탄 = 힘", "...", "소지한 폭탄 하나당 공격력(고정) 0.16 증가합니다.#중첩이 가능합니다.")
end

local BOMB_IS_POWER_INCREMENT = 0.16

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(AstroItems.Collectible.BOMB_IS_POWER) then
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

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end,
    AstroItems.Collectible.BOMB_IS_POWER
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.BOMB_IS_POWER) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + player:GetNumBombs() * player:GetCollectibleNum(AstroItems.Collectible.BOMB_IS_POWER) * BOMB_IS_POWER_INCREMENT
            end
        end
    end
)

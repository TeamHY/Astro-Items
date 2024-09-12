---
local REINCARNATION_ITEMS = {
    CollectibleType.COLLECTIBLE_1UP,
    CollectibleType.COLLECTIBLE_LAZARUS_RAGS,
    CollectibleType.COLLECTIBLE_ANKH,
    AstroItems.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL
}

local REINCARNATION_DAMAGE_MULTIPLIER = 0.5
---

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.REINCARNATION = Isaac.GetItemIdByName("Reincarnation")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.REINCARNATION,
        "리인카네이션",
        "...",
        "다음 게임 시작 시 부활 아이템 중 하나가 소환됩니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.RunReincarnation then
            local player = Isaac.GetPlayer()
            local rng = player:GetCollectibleRNG(AstroItems.Collectible.REINCARNATION)

            local item = AstroItems:GetRandomCollectibles(REINCARNATION_ITEMS, rng, 1)[1]
            AstroItems:SpawnCollectible(item, player.Position)

            AstroItems.Data.RunReincarnation = false
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if collectibleType == AstroItems.Collectible.REINCARNATION then
            AstroItems.Data.RunReincarnation = true
        elseif AstroItems:Contain(REINCARNATION_ITEMS, collectibleType) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:Contain(REINCARNATION_ITEMS, collectibleType) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.REINCARNATION) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                local count = 0

                for _, item in ipairs(REINCARNATION_ITEMS) do
                    count = count + player:GetCollectibleNum(item)
                end

                player.Damage = player.Damage * (1 + REINCARNATION_DAMAGE_MULTIPLIER * count * player:GetCollectibleNum(AstroItems.Collectible.REINCARNATION))
            end
        end
    end
)

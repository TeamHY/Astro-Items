---

local MIN_DAMAGE_MULTIPLIER = 1.5
local MAX_DAMAGE_MULTIPLIER = 2.0

---

local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.TERRA_EX = Isaac.GetItemIdByName("TERRA EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.TERRA_EX,
        "초 지구",
        "...",
        "{{Collectible592}}Terra 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#방 입장 시 {{DamageSmall}}공격력이 x1.5 ~ x2 증가합니다. 중첩이 가능합니다." ..
        "#방 클리어 시 {{Card32}}Hagalaz를 발동합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.TERRA_EX) then
                player:UseCard(Card.RUNE_HAGALAZ, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.TERRA_EX) then
                local data = AstroItems:GetPersistentPlayerData(player)
                
                if data then
                    local rng = player:GetCollectibleRNG(AstroItems.Collectible.TERRA_EX)
                    local range = MAX_DAMAGE_MULTIPLIER - MIN_DAMAGE_MULTIPLIER
        
                    data["terraEXDamageMultiplier"] = 1

                    for _ = 1, player:GetCollectibleNum(AstroItems.Collectible.TERRA_EX) do
                        data["terraEXDamageMultiplier"] = data["terraEXDamageMultiplier"] * (rng:RandomFloat() * range + MIN_DAMAGE_MULTIPLIER)
                    end

                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.TERRA_EX) then
            local data = AstroItems:GetPersistentPlayerData(player)

            if data and data["terraEXDamageMultiplier"] then
                player.Damage = player.Damage * data["terraEXDamageMultiplier"]
            end
        end
    end,
    CacheFlag.CACHE_DAMAGE
)


AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_TERRA)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_TERRA) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_TERRA)
        end
    end,
    AstroItems.Collectible.TERRA_EX
)

-- AstroItems:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_TERRA) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_TERRA)
--         end
--     end,
--     AstroItems.Collectible.TERRA_EX
-- )

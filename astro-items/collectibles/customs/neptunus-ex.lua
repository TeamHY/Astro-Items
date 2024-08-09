---

local TEARS_INCREMENT = 0.1

---

local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.NEPTUNUS_EX = Isaac.GetItemIdByName("NEPTUNUS EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.NEPTUNUS_EX,
        "초 해왕성",
        "...",
        "{{Collectible597}}Neptunus 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#방 클리어 시 {{TearsSmall}}연사(고정) 0.25 증가합니다. 중첩이 가능합니다. 스테이지 입장 시 초기화 됩니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.NEPTUNUS_EX) then
                local data = AstroItems:GetPersistentPlayerData(player)
                
                if data then
                    data["neptunusEXTears"] = 0

                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:EvaluateItems()
                end
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            
            if player:HasCollectible(AstroItems.Collectible.NEPTUNUS_EX) then
                local data = AstroItems:GetPersistentPlayerData(player)

                if data then
                    if data["neptunusEXTears"] == nil then
                        data["neptunusEXTears"] = 0
                    end

                    data["neptunusEXTears"] = data["neptunusEXTears"] + TEARS_INCREMENT * player:GetCollectibleNum(AstroItems.Collectible.NEPTUNUS_EX)

                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
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
        if player:HasCollectible(AstroItems.Collectible.NEPTUNUS_EX) then
            local data = AstroItems:GetPersistentPlayerData(player)

            if data and data["neptunusEXTears"] then
                player.MaxFireDelay = AstroItems:AddTears(player.MaxFireDelay, data["neptunusEXTears"])
            end
        end
    end,
    CacheFlag.CACHE_FIREDELAY
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_NEPTUNUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_NEPTUNUS)
        end
    end,
    AstroItems.Collectible.NEPTUNUS_EX
)

-- AstroItems:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_NEPTUNUS) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_NEPTUNUS)
--         end
--     end,
--     AstroItems.Collectible.NEPTUNUS_EX
-- )

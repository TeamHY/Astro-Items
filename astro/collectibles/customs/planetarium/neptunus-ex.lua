---

local TEARS_INCREMENT = 0.05

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.NEPTUNUS_EX = Isaac.GetItemIdByName("NEPTUNUS EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.NEPTUNUS_EX,
        "초 해왕성",
        "...",
        "{{Collectible597}} Neptunus 효과가 적용됩니다." ..
        "#방 클리어 시 {{TearsSmall}}연사(고정) +0.05" ..
        "#{{ArrowGrayRight}} 스테이지 입장 시 초기화됩니다." ..
        "#{{ArrowGrayRight}} 중첩이 가능합니다." ..
        "#!!! 이번 게임에서 {{Collectible597}}Neptunus가 등장하지 않습니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.NEPTUNUS_EX) then
                local data = Astro:GetPersistentPlayerData(player)
                
                if data then
                    data["neptunusEXTears"] = 0

                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            
            if player:HasCollectible(Astro.Collectible.NEPTUNUS_EX) then
                local data = Astro:GetPersistentPlayerData(player)

                if data then
                    if data["neptunusEXTears"] == nil then
                        data["neptunusEXTears"] = 0
                    end

                    data["neptunusEXTears"] = data["neptunusEXTears"] + TEARS_INCREMENT * player:GetCollectibleNum(Astro.Collectible.NEPTUNUS_EX)

                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.NEPTUNUS_EX) then
            local data = Astro:GetPersistentPlayerData(player)

            if data and data["neptunusEXTears"] then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, data["neptunusEXTears"])
            end
        end
    end,
    CacheFlag.CACHE_FIREDELAY
)

Astro:AddCallbackCustom(
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
    Astro.Collectible.NEPTUNUS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_NEPTUNUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_NEPTUNUS)
        end
    end,
    Astro.Collectible.NEPTUNUS_EX
)

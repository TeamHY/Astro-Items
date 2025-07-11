---

local ALL_STAT_MULTIPLIER = 1.1

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.ALBIREO = Isaac.GetItemIdByName("Albireo")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.ALBIREO,
                "알비레오",
                "...",
                "!!! 일회용 (스텔라 제외)" ..
                "#사용 시 방에 있는 별자리/행성 아이템이 강화됩니다." ..
                "#{{Collectible" .. Astro.Collectible.CYGNUS .. "}}Cygnus 소지 시;#{{ArrowGrayRight}} 모든 능력치 x1.1"
            )
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
        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = entity:ToPickup()
            local id = pickup.SubType

            if Astro.PLANETARIUM_UPGRADE_LIST[id] then
                pickup:Morph(pickup.Type, pickup.Variant, Astro.PLANETARIUM_UPGRADE_LIST[id].Id, true)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, pickup.Position, pickup.Velocity, playerWhoUsedItem)
            end
        end

        if playerWhoUsedItem:GetPlayerType() == Astro.Players.STELLAR then
            return {
                Discharge = true,
                Remove = false,
                ShowAnim = true,
            }
        end

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.ALBIREO
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if player:HasCollectible(Astro.Collectible.ALBIREO) then
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        end
    end,
    Astro.Collectible.CYGNUS
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@diagnostic disable-next-line: param-type-mismatch
    Astro.CallbackPriority.MULTIPLY,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function (_, player, cacheFlag)
        if not player:HasCollectible(Astro.Collectible.ALBIREO) or not player:HasCollectible(Astro.Collectible.CYGNUS) then return end

        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = ((player.MaxFireDelay + 1) / ALL_STAT_MULTIPLIER) - 1
        end

        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_LUCK and player.Luck > 0 then
            player.Luck = player.Luck * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * ALL_STAT_MULTIPLIER
        end

        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed * ALL_STAT_MULTIPLIER
        end
    end
)

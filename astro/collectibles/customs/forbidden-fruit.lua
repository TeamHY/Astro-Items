Astro.Collectible.FORBIDDEN_FRUIT = Isaac.GetItemIdByName("Forbidden Fruit")

---

local DAMAGE_MODE_DAMAGE = 1.5
local DAMAGE_MODE_TEARS = 0.8

local TEARS_MODE_DAMAGE = 0.8
local TEARS_MODE_TEARS = 1.5

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.FORBIDDEN_FRUIT,
                "선악과",
                "금지된 열매",
                "#소지중일 때 모드에 따라 능력치가 증가합니다." ..
                "사용 시 모드를 전환합니다." ..
                "#{{Damage}} 공격력 모드:" ..
                "#{{IND}}↓ {{TearsSmall}}연사 배율 x" .. DAMAGE_MODE_TEARS ..
                "#{{IND}}↑ {{DamageSmall}}공격력 배율 x" .. DAMAGE_MODE_DAMAGE ..
                "#{{Tears}} 연사 모드:" ..
                "#{{IND}}↑ {{TearsSmall}}연사 배율 x" .. TEARS_MODE_TEARS ..
                "#{{IND}}↓ {{DamageSmall}}공격력 배율 x" .. TEARS_MODE_DAMAGE
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.FORBIDDEN_FRUIT,
                "Forbidden Fruit", "",
                "Holding the item causes a stat boost" ..
                "#On use, switch between damage mode and tears mode" ..
                "#{{Damage}} Damage mode:" ..
                "#{{IND}}↓ {{TearsSmall}} x" .. DAMAGE_MODE_TEARS .. " Fire rate multiplier" ..
                "#{{IND}}↑ {{DamageSmall}} x" .. DAMAGE_MODE_DAMAGE .. " Damage multiplier" ..
                "#{{Tears}} Tears mode:" ..
                "#{{IND}}↑ {{TearsSmall}} x" .. TEARS_MODE_TEARS .. " Fire rate multiplier" ..
                "#{{IND}}↓ {{DamageSmall}} x" .. TEARS_MODE_DAMAGE .. " Damage multiplier",
                nil, "en_us"
            )
        end
    end
)

---@param isTears boolean
local function checkFruitMode(isTears)
    if isTears then
        return {
            damage = TEARS_MODE_DAMAGE,
            tears = TEARS_MODE_TEARS
        }
    else
        return {
            damage = DAMAGE_MODE_DAMAGE,
            tears = DAMAGE_MODE_TEARS
        }
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.ForbiddenFruitMode = true
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
        Astro.Data.ForbiddenFruitMode = not Astro.Data.ForbiddenFruitMode

        playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        playerWhoUsedItem:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.FORBIDDEN_FRUIT
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.MULTIPLY,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.FORBIDDEN_FRUIT) then
            local extraStat = checkFruitMode(Astro.Data.ForbiddenFruitMode)

            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = (player.MaxFireDelay + 1) / (extraStat.tears) - 1
            elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage * extraStat.damage
            end
        end
    end
)
Astro.Collectible.DAVIDS_STONE = Isaac.GetItemIdByName("David's Stone")

---

local DAMAGE_INCREMENT = 1.5

local TEARS_INCREMENT = 0.2

local SPEED_INCREMENT = 0.2

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_SMALL_ROCK].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible90}}{{ColorYellow}}작은 돌{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible90}} {{ColorYellow}}The Small Rock{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.DAVIDS_STONE, CRAFT_HINT)

            Astro.EID:AddCollectible(
                Astro.Collectible.DAVIDS_STONE,
                "다윗의 물맷돌",
                "칼도 없이 돌덩이 하나로",
                "↑ {{DamageSmall}}공격력 +" .. DAMAGE_INCREMENT ..
                "#↑ {{TearsSmall}}연사(+상한) +" .. TEARS_INCREMENT ..
                "#↑ {{SpeedSmall}}이동속도 +" .. SPEED_INCREMENT,
                -- 중첩 시
                "중첩 가능"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.DAVIDS_STONE,
                "David's Stone", "",
                "↑ {{Speed}} +" .. SPEED_INCREMENT .. " Speed" ..
                "#↑ {{Tears}} +" .. TEARS_INCREMENT .. " Fire rate" ..
                "#↑ {{Damage}} +" .. DAMAGE_INCREMENT .. " Damage",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.DAVIDS_STONE) then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.DAVIDS_STONE)

            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + (DAMAGE_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, TEARS_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + (SPEED_INCREMENT * itemCount)
            end
        end
    end
)
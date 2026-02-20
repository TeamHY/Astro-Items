---

local DAMAGE_INCREMENT = 1

local TEARS_INCREMENT = 0.5

local RANGE_INCREMENT = 2.5

local SHOTSPEED_INCREMENT = 0.2

local SPEED_INCREMENT = 0.2

local LUCK_INCREMENT = 1

---

Astro.Collectible.EXPERIMENTAL_SERUM = Isaac.GetItemIdByName("Experimental Serum")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible240}}{{ColorYellow}}임상시험{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible240}} {{ColorYellow}}Experimental Treatment{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.EXPERIMENTAL_SERUM, CRAFT_HINT)

            Astro.EID:AddCollectible(
                Astro.Collectible.EXPERIMENTAL_SERUM,
                "실험용 혈청",
                "모든 능력치 증가!",
                "↑ {{TearsSmall}}연사 +" .. TEARS_INCREMENT ..
                "#↑ {{DamageSmall}}공격력 +" .. DAMAGE_INCREMENT ..
                "#↑ {{SpeedSmall}}이동속도 +" .. SPEED_INCREMENT ..
                "#↑ {{RangeSmall}}사거리 +" .. RANGE_INCREMENT ..
                "#↑ {{ShotspeedSmall}}탄속 +" .. SHOTSPEED_INCREMENT ..
                "#↑ {{LuckSmall}}행운 +" .. LUCK_INCREMENT ..
                "#↑ {{Heart}}최대 체력 +1",
                -- 중첩 시
                "중첩 가능"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.EXPERIMENTAL_SERUM,
                "Experimental Serum", "",
                "↑ {{Tears}} +" .. TEARS_INCREMENT .. " Fire rate" ..
                "#↑ {{Damage}} +" .. DAMAGE_INCREMENT .. " Damage" ..
                "#↑ {{Speed}} +" .. SPEED_INCREMENT .. " Speed" ..
                "#↑ {{Range}} +" .. RANGE_INCREMENT .. " Range" ..
                "#↑ {{Shotspeed}} +" .. SHOTSPEED_INCREMENT .. " Shot speed" ..
                "#↑ {{Luck}} +" .. LUCK_INCREMENT .. " Luck" ..
                "#↑ {{Heart}} +1 Health",
                -- Stacks
                "Stackable",
                "en_us"
            )
            
            EID.HealthUpData["5.100." .. tostring(Astro.Collectible.EXPERIMENTAL_SERUM)] = 1
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.EXPERIMENTAL_SERUM) then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.EXPERIMENTAL_SERUM)

            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + (DAMAGE_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, TEARS_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_RANGE then
                player.TearRange = player.TearRange + ((RANGE_INCREMENT * 40) * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
                player.ShotSpeed = player.ShotSpeed + (SHOTSPEED_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + (SPEED_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + (LUCK_INCREMENT * itemCount)
            end
        end
    end
)

Astro.Collectible.RAINBOW_MUSHROOM = Isaac.GetItemIdByName("Rainbow Mushroom")

---

local DAMAGE_INCREMENT = 0.5

local DAMAGE_MULTIPLIER = 1.5

local RANGE_INCREMENT = 2.5

local SPEED_INCREMENT = 0.3

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible12}}{{ColorYellow}}마법의 버섯{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible12}} {{ColorYellow}}Magic Mushroom{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.RAINBOW_MUSHROOM, CRAFT_HINT)

            Astro.EID:AddCollectible(
                Astro.Collectible.RAINBOW_MUSHROOM,
                "무지개 버섯",
                "말이 필요해? 모든 능력치 증가!",
                "↑ {{DamageSmall}}공격력 배율 x" .. DAMAGE_MULTIPLIER ..
                "#↑ {{DamageSmall}}공격력 +" .. DAMAGE_INCREMENT ..
                "#↑ {{SpeedSmall}}이동속도 +" .. SPEED_INCREMENT ..
                "#↑ {{RangeSmall}}사거리 +" .. RANGE_INCREMENT ..
                "#↑ {{Heart}}최대 체력 +1" ..
                "#{{HealingRed}} 체력을 모두 회복합니다.",
                -- 중첩 시
                "중첩 시 합연산으로 계산"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.RAINBOW_MUSHROOM,
                "Rainbow Mushroom", "",
                "↑ {{Damage}} x" .. DAMAGE_MULTIPLIER .. " Damage multiplier" ..
                "#↑ {{Damage}} +" .. DAMAGE_INCREMENT .. " Damage" ..
                "#↑ {{Speed}} +" .. SPEED_INCREMENT .. " Speed" ..
                "#↑ {{Range}} +" .. RANGE_INCREMENT .. " Range" ..
                "#↑ {{Heart}} +1 Health" ..
                "#{{HealingRed}} Full health" ..
                "#!!! Stackable",
                nil, "en_us"
            )
            
            EID.HealthUpData["5.100." .. tostring(Astro.Collectible.RAINBOW_MUSHROOM)] = 1
            EID.BloodUpData[Astro.Collectible.RAINBOW_MUSHROOM] = 12
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.RAINBOW_MUSHROOM) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM,
                        modifierName = "Rainbow Mushroom"
                    }
                end
        
                return false
            end
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.RAINBOW_MUSHROOM) then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.RAINBOW_MUSHROOM)

            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + (DAMAGE_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_RANGE then
                player.TearRange = player.TearRange + ((RANGE_INCREMENT * 40) * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + (SPEED_INCREMENT * itemCount)
            end
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.MULTIPLY,
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.RAINBOW_MUSHROOM) and cacheFlag == CacheFlag.CACHE_DAMAGE then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.RAINBOW_MUSHROOM)

            player.Damage = player.Damage * (DAMAGE_MULTIPLIER * itemCount)
        end
    end
)

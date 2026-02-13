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
            Astro.EID:AddCollectible(
                Astro.Collectible.EXPERIMENTAL_SERUM,
                "실험용 혈청",
                "...",
                "↑ {{Heart}}최대 체력 +1" ..
                "#↑ {{DamageSmall}}공격력 +" .. DAMAGE_INCREMENT ..
                "#↑ {{TearsSmall}}연사 +" .. TEARS_INCREMENT ..
                "#↑ {{RangeSmall}}사거리 +" .. RANGE_INCREMENT ..
                "#↑ {{ShotspeedSmall}}탄속 +" .. SHOTSPEED_INCREMENT ..
                "#↑ {{SpeedSmall}}이동속도 +" .. SPEED_INCREMENT ..
                "#↑ {{LuckSmall}}행운 +" .. LUCK_INCREMENT,
                -- 중첩 시
                "중첩 가능"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.EXPERIMENTAL_SERUM,
                "Experimental Serum",
                "...",
                "↑ {{Heart}} +1 Health" ..
                "#↑ {{Damage}} +" .. DAMAGE_INCREMENT .. " Damage" ..
                "#↑ {{Tears}} +" .. TEARS_INCREMENT .. " Tears" ..
                "#↑ {{Range}} +" .. RANGE_INCREMENT .. " Range" ..
                "#↑ {{Shotspeed}} +" .. SHOTSPEED_INCREMENT .. " Shot Speed" ..
                "#↑ {{Speed}} +" .. SPEED_INCREMENT .. " Speed" ..
                "#↑ {{Luck}} +" .. LUCK_INCREMENT .. " Luck",
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

Astro.Collectible.SEVEN_SEVEN_SEVEN = Isaac.GetItemIdByName("777")

---

local DAMAGE_INCREMENT = 1

local SPEED_INCREMENT = 0.2

local ETERNAL_HEART_COUNT = 2

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.SEVEN_SEVEN_SEVEN,
                "777",
                "신성함",
                "↑ {{DamageSmall}}공격력 +" .. DAMAGE_INCREMENT ..
                "#↑ {{SpeedSmall}}이동속도 +" .. SPEED_INCREMENT ..
                "#{{EternalHeart}} 이터널하트를 " .. ETERNAL_HEART_COUNT .. "개 드랍합니다.",
                -- 중첩 시
                "중첩 가능"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.SEVEN_SEVEN_SEVEN,
                "777", "",
                "↑ {{Damage}} +" .. DAMAGE_INCREMENT .. " Damage" ..
                "#↑ {{Speed}} +" .. SPEED_INCREMENT .. " Speed" ..
                "#{{EternalHeart}} Spawns " .. ETERNAL_HEART_COUNT .. " Eternal Hearts",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.SEVEN_SEVEN_SEVEN) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_MARK,
                        modifierName = "777"
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
        if player:HasCollectible(Astro.Collectible.SEVEN_SEVEN_SEVEN) then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.SEVEN_SEVEN_SEVEN)

            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + (DAMAGE_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + (SPEED_INCREMENT * itemCount)
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.SEVEN_SEVEN_SEVEN) then
            for _ = 1, ETERNAL_HEART_COUNT do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, Isaac.GetFreeNearPosition(player.Position, 40), Vector(0, 0), player)
            end
        end
    end,
    Astro.Collectible.SEVEN_SEVEN_SEVEN
)

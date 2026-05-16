Astro.Collectible.LIBERATION = Isaac.GetItemIdByName("Liberation")

---

local DAMAGE_INCREMENT = 0.5

local TEARS_INCREMENT = 0.7

local ETERNAL_HEART_COUNT = 4

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.LIBERATION,
                "해방",
                "마침내 자유가 되리",
                "↑ {{TearsSmall}}연사(+상한) +" .. TEARS_INCREMENT ..
                "#↑ {{DamageSmall}}공격력 +" .. DAMAGE_INCREMENT ..
                "#{{EternalHeart}} 이터널하트를 " .. ETERNAL_HEART_COUNT .. "개 드랍합니다.",
                -- 중첩 시
                "중첩 가능"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.LIBERATION,
                "Liberation", "",
                "↑ {{Tears}} +" .. TEARS_INCREMENT .. " Fire rate" ..
                "#↑ {{Damage}} +" .. DAMAGE_INCREMENT .. " Damage" ..
                "#{{EternalHeart}} Spawns " .. ETERNAL_HEART_COUNT .. " Eternal Hearts",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.LIBERATION) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_PACT,
                        modifierName = "Liberation"
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
        if player:HasCollectible(Astro.Collectible.LIBERATION) then
            local itemCount = player:GetCollectibleNum(Astro.Collectible.LIBERATION)

            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + (DAMAGE_INCREMENT * itemCount)
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, TEARS_INCREMENT * itemCount)
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.LIBERATION) then
            for _ = 1, ETERNAL_HEART_COUNT do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, Isaac.GetFreeNearPosition(player.Position, 40), Vector(0, 0), player)
            end
        end
    end,
    Astro.Collectible.LIBERATION
)

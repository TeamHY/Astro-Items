Astro.Trinket.FLUNK = Isaac.GetTrinketIdByName("Flunk")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDTrinket(
                Astro.Trinket.FLUNK,
                "낙제",
                "행운 감소? 아무튼 잃지 말라구!",
                "↓ {{LuckSmall}}행운 -2" ..
                "#{{Trinket145}} Perfection과 같은 판정을 가집니다.",
                -- 황금
                "행운 감소 페널티 무효화"
            )

            EID:addCondition(
                "5.350." .. tostring(Astro.Trinket.FLUNK),
                { "5.100." .. tostring(Astro.Collectible.EZ_MODE) },
                "피격을 당해도 사라지지 않음",
                nil, "ko_kr", nil
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player ~= nil and player:HasTrinket(Astro.Trinket.FLUNK) and not player:HasCollectible(Astro.Collectible.EZ_MODE) then
            if damageFlags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS) == 0 then
                Astro:RemoveAllTrinket(player, Astro.Trinket.FLUNK)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasTrinket(Astro.Trinket.FLUNK) then
            player.Luck = player.Luck - 2

            if player:GetTrinketMultiplier(Astro.Trinket.FLUNK) > 1 then
                player.Luck = player.Luck + 2
            end
        end
    end,
    CacheFlag.CACHE_LUCK
)

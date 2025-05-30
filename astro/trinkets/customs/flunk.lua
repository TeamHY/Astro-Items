Astro.Trinket.FLUNK = Isaac.GetTrinketIdByName("Flunk")

if EID then
    EID:addTrinket(
        Astro.Trinket.FLUNK,
        "#↓ 행운 -2#{{ArrowGrayRight}} {{ColorGold}}행운 감소 효과가 적용되지 않습니다.{{CR}}#{{Trinket145}} Perfection과 같은 판정을 가집니다.#{{Collectible" .. Astro.Collectible.EZ_MODE .. "}}EZ Mode 소지 시 사라지지 않습니다.",
        "낙제"
    )

    -- Astro:AddGoldenTrinketDescription(Astro.Trinket.FLUNK, "")
end

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

Astro.Collectible.EZ_MODE = Isaac.GetItemIdByName("EZ Mode")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.EZ_MODE, "쉬운 모드", "...", "↓ {{LuckSmall}}행운 -2#후반 스테이지 진입 전까지 피격 페널티가 발생하지 않습니다.#소울 하트 1개가 증가됩니다.")
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

        if player ~= nil and not Astro:IsLatterStage() then
            if player:HasCollectible(Astro.Collectible.EZ_MODE) then
                if damageFlags & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
                    player:TakeDamage(amount, damageFlags | DamageFlag.DAMAGE_NO_PENALTIES, source, countdownFrames)
                    return false
                end
            end
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function (_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.EZ_MODE) then
            player.Luck = player.Luck - 2
        end
    end,
    CacheFlag.CACHE_LUCK
)

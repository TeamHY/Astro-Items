local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.PROMETHEUS = Isaac.GetItemIdByName("Prometheus")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.PROMETHEUS, "프로메테우스", "...", "항상 다크니스 저주가 활성화됩니다.#↑ {{DamageSmall}}공격력 x1.25#중첩이 가능합니다.")
end

-- !!! astro/init.lua로 이동
-- Astro:AddPriorityCallback(
--     ModCallbacks.MC_POST_CURSE_EVAL,
--     CallbackPriority.DEFAULT,
--     ---@param curses integer
--     function(curses)
--         local hasPrometheus = false

--         for i = 1, Game():GetNumPlayers() do
--             local player = Isaac.GetPlayer(i - 1)

--             if player:HasCollectible(Astro.Collectible.PROMETHEUS) then
--                 hasPrometheus = true
--             end

--             if Astro:HasPerfectionEffect(player) then
--                 return curses
--             end
--         end

--         if hasPrometheus then
--             return curses | LevelCurse.CURSE_OF_DARKNESS
--         end
--     end
-- )

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local level = Game():GetLevel()

        if Astro and not Astro:HasPerfectionEffect(player) then
            level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, true)
        elseif not Astro then
            level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, true)
        end
    end,
    AstroItems.Collectible.PROMETHEUS
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.PROMETHEUS) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage * 1.25 ^ player:GetCollectibleNum(AstroItems.Collectible.PROMETHEUS)
            end
        end
    end
)

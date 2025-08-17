local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.PROMETHEUS = Isaac.GetItemIdByName("Prometheus")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.PROMETHEUS, "프로메테우스", "불을 훔친 자", "↑ {{DamageSmall}}공격력 x1.25#항상 {{CurseDarknessSmall}}Curse of Dakrness 저주에 걸립니다.#중첩이 가능합니다.")
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

Astro:AddCallbackCustom(
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
    Astro.Collectible.PROMETHEUS
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.PROMETHEUS) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage * 1.25 ^ player:GetCollectibleNum(Astro.Collectible.PROMETHEUS)
            end
        end
    end
)

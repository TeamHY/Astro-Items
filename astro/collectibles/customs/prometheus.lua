Astro.Collectible.PROMETHEUS = Isaac.GetItemIdByName("Prometheus")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.PROMETHEUS,
                "프로메테우스",
                "불을 훔친 자",
                "↑ {{DamageSmall}}공격력 x1.35" ..
                "#{{CurseDarknessSmall}} 항상 Curse of Dakrness 저주에 걸립니다." ..
                "#방 입장 시 모든 모닥불이 자동으로 꺼집니다.",
                -- 중첩 시
                "중첩 가능"
            )
            
            Astro:AddEIDCollectible(
                Astro.Collectible.PROMETHEUS,
                "Prometheus",
                "",
                "↑ {{Damage}} x1.35 Damage multiplier" ..
                "#{{CurseDarkness}} Curse of Darkness effect for the rest of the run" ..
                "#Automatically extinguishes all fire places on room entry",
                -- Stacks
                "Stackable",
                "en_us"
            )
        end
    end
)
-- !!! astro/curse.lua로 이동
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

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local level = Game():GetLevel()

        if Astro.IsFight and not Astro:HasPerfectionEffect(player) then
            level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, false)
        else
            level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, false)
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
                player.Damage = player.Damage * 1.35 ^ player:GetCollectibleNum(Astro.Collectible.PROMETHEUS)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.PROMETHEUS) then
            local fires = Isaac.FindByType(EntityType.ENTITY_FIREPLACE)
            
            for _, fire in ipairs(fires) do
                fire:Kill()
            end
        end
    end
)
Astro:AddCallback(
    ModCallbacks.MC_POST_CURSE_EVAL,
    function(_, curse)
        if not Astro.IsFight then
            local hasPrometheus = 0
            local hasDango = 0
            local hasCurseCleaner = false

            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.PROMETHEUS) then
                    hasPrometheus = LevelCurse.CURSE_OF_DARKNESS
                end

                if player:HasCollectible(Astro.Collectible.DANGO) then
                    hasDango = LevelCurse.CURSE_OF_MAZE
                    hasCurseCleaner = true
                end

                if player:HasTrinket(Astro.Trinket.DOCTRINE) then
                    hasCurseCleaner = true
                end
            end

            if not hasCurseCleaner then
                return curse | hasPrometheus
            end

            if hasCurseCleaner then
                return hasDango
            end
        end
    end
)

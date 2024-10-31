Astro:AddCallback(
    ModCallbacks.MC_POST_CURSE_EVAL,
    function(_, curse)
        if not Astro then
            local hasPrometheus = false
            local hasCurseCleaner = false

            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.PROMETHEUS) then
                    hasPrometheus = true
                end

                if player:HasTrinket(Astro.Trinket.DOCTRINE) then
                    hasCurseCleaner = true
                end
            end

            if hasPrometheus and not hasCurseCleaner then
                return curse | LevelCurse.CURSE_OF_DARKNESS
            end

            if hasCurseCleaner then
                return 0
            end
        end
    end
)

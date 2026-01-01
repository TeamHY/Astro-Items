Astro.Collectible.DANGO = Isaac.GetItemIdByName("Dango")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.DANGO,
                "경단",
                "버림받은 기분",
                "↑ {{Heart}}최대 체력 +1" ..
                "#↑ {{HealingRed}}빨간하트 +1" ..
                "#{{CurseMazeSmall}} 항상 Maze 저주에 걸리며;" ..
                "#{{ArrowGrayRight}} Maze 저주를 제외한 모든 저주에 면역이 됩니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.DANGO,
                "Dango",
                "",
                "↑ {{Heart}} +1 Health" ..
                "#{{HealingRed}} Heals 1 heart" ..
                "#{{CurseBlind}} Immune to curses except the Curse of the Maze" ..
                "#{{CurseMaze}} Curse of the Maze effect for the rest of the run",
                nil, "en_us"
            )

            EID.HealthUpData["5.100." .. tostring(Astro.Collectible.DANGO)] = 1
            EID.BloodUpData[Astro.Collectible.DANGO] = 4
        end

        -- 대결 밴
        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro.IsFight and selectedCollectible == Astro.Collectible.DANGO then
                    return {
                        reroll = true,
                        modifierName = "Dango"
                    }
                end
        
                return false
            end
        )
    end
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local level = Game():GetLevel()

        level:RemoveCurses(255)
        if Astro.IsFight and not Astro:HasPerfectionEffect(player) then
            level:AddCurse(LevelCurse.CURSE_OF_MAZE, false)
        else
            level:AddCurse(LevelCurse.CURSE_OF_MAZE, false)
        end
    end,
    Astro.Collectible.DANGO
)
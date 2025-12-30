Astro.Collectible.CANNED_BREAD = Isaac.GetItemIdByName("Canned Bread")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.CANNED_BREAD,
                "빵 통조림",
                "여기 있네!",
                "↑ {{Heart}}최대 체력 +1" ..
                "#↑ {{HealingRed}}빨간하트 +1"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.CANNED_BREAD,
                "Canned Bread",
                "",
                "↑ {{Heart}} +1 Health" ..
                "#{{HealingRed}} Heals 1 heart",
                nil, "en_us"
            )

            EID.HealthUpData["5.100." .. tostring(Astro.Collectible.CANNED_BREAD)] = 1
            EID.BloodUpData[Astro.Collectible.CANNED_BREAD] = 4
        end

        -- 대결 밴
        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro.IsFight and selectedCollectible == Astro.Collectible.CANNED_BREAD then
                    return {
                        reroll = true,
                        modifierName = "Canned Bread"
                    }
                end
        
                return false
            end
        )
    end
)
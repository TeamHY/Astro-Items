Astro.Collectible.ANOREXIA_NERVOSA = Isaac.GetItemIdByName("Anorexia Nervosa")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ANOREXIA_NERVOSA,
                "거식증",
                "식욕이 없어요...",
                "↑ {{EmptyHeart}}빈 최대 체력 +3" ..
                "#음식 관련({{Heart}}최대 체력 증가) 아이템이 등장하지 않습니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.ANOREXIA_NERVOSA,
                "Anorexia Nervosa",
                "",
                "↑ {{EmptyHeart}} +3 Empty heart containers" ..
                "#Prevents Food({{Heart}} health up) items from spawning",
                nil, "en_us"
            )

            EID.HealthUpData["5.100." .. tostring(Astro.Collectible.ANOREXIA_NERVOSA)] = 3
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                local itemConfig = Isaac.GetItemConfig()

                if Astro:HasCollectible(Astro.Collectible.ANOREXIA_NERVOSA) and (itemConfig:GetCollectible(selectedCollectible).Tags & ItemConfig.TAG_FOOD == ItemConfig.TAG_FOOD) then
                    return {
                        reroll = true,
                        modifierName = "Anorexia Nervosa"
                    }
                end

                return false
            end
        )
    end
)

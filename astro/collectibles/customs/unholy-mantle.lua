Astro.Collectible.UNHOLY_MANTLE = Isaac.GetItemIdByName("Unholy Mantle")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.UNHOLY_MANTLE,
                "불경스런 망토",
                "타락한 방패",
                "{{Collectible313}} Holy Mantle 효과 발동:" ..
                "#{{IND}}{{HolyMantleSmall}} 피격 시 방당 1회 한정으로 피해를 무시합니다." ..
                "#!!! 헌혈류 피격은 막아주지 않습니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.UNHOLY_MANTLE,
                "Unholy Mantle", "",
                "{{Collectible313}} Holy Mantle effect applied:" ..
                "#{{IND}}{{HolyMantle}} Negates the first hit taken once per room",
                nil, "en_us"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.UNHOLY_MANTLE) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_HOLY_MANTLE,
                        modifierName = "Unholy Mantle"
                    }
                end
        
                return false
            end
        )

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if not Astro.IsFight then
                    return {
                        reroll = selectedCollectible == Astro.Collectible.UNHOLY_MANTLE,
                        modifierName = "Unholy Mantle (not Astro-rules)"
                    }
                end
        
                return false
            end
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        Astro:ScheduleForUpdate(
            function()
                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)
                
                    if player:HasCollectible(Astro.Collectible.UNHOLY_MANTLE) then
                        Isaac.GetPlayer(0):UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                    end
                end
            end,
            1
        )
    end
)

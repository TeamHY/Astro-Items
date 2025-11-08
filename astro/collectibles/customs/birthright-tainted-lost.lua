Astro.Collectible.BIRTHRIGHT_TAINTED_LOST = Isaac.GetItemIdByName("Birthright - Tainted Lost")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_TAINTED_LOST,
                "더럽혀진 로스트의 생득권",
                "더 나은 운명?",
                "↑ 소지중일 때 목숨 +1" ..
                "#{{Quality0}}/{{Quality1}}/{{Quality2}}등급 아이템 등장 시 다른 아이템으로 바꿉니다." ..
                "#{{Blank}} {{ColorGray}}(바뀐 아이템은 콘솔에서 확인 가능){{CR}}"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)
        
                if Astro:HasCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST) then
                    return {
                        reroll = itemConfigitem.Quality <= 2,
                        modifierName = "Birthright - Tainted Lost"
                    }
                end
        
                return false
            end
        )
    end
)

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH,
        function(_, player)
            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST, true) then
                player:RemoveCollectible(Astro.Collectible.BIRTHRIGHT_TAINTED_LOST)
                player:SetMinDamageCooldown(120)
                return false
            end
        end
    )
end

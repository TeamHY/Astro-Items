Astro.Collectible.BIRTHRIGHT_APOLLYON_B = Isaac.GetItemIdByName("Birthright - Apollyon B")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_APOLLYON_B,
                "더럽혀진 아폴리온의 생득권",
                "재앙의 동료",
                "{{Collectible706}} 클리어하지 않은 방에 입장 시 심연의 파리 3마리를 소환합니다.",
                -- 중첩 시
                "중첩된 수만큼 소환 시도"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Game():GetRoom():IsClear() then return end

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_APOLLYON_B) then
                local num = player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_APOLLYON_B)

                if num >= 1 then
                    for _ = 1, num do
                        player:UseCard(Card.RUNE_BERKANO, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
                    end
                end
            end
        end
    end
)

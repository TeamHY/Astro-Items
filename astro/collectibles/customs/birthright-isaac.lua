Astro.Collectible.BIRTHRIGHT_ISAAC = Isaac.GetItemIdByName("Birthright - Isaac")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_ISAAC,
                "아이작의 생득권",
                "추가 선택지",
                "{{Card81}} 그 방의 아이템이 랜덤 아이템과 1초마다 전환되며 두 아이템 중 하나를 선택할 수 있습니다.",
                -- 중첩 시
                "선택 가능한 아이템 수가 중첩된 수만큼 증가"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()

        if currentRoom:GetFrameCount() <= 0 and currentRoom:IsFirstVisit() and not Astro:IsDeathCertificateRoom() then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
            
                if player:HasCollectible(Astro.Collectible.BIRTHRIGHT_ISAAC) then
                    for _ = 1, player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_ISAAC) do
                        player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                    end
                end
            end
        end
    end
)

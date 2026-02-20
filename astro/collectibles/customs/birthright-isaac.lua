Astro.Collectible.BIRTHRIGHT_ISAAC = Isaac.GetItemIdByName("Isaac's Frame")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_ISAAC,
                "아이작의 액자",
                "추가 선택지",
                "{{Player21}} 모든 받침대 아이템이 2개의 선택지를 지닙니다.",
                -- 중첩 시
                "선택 가능한 아이템 수가 중첩된 수만큼 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_ISAAC,
                "Isaac's Frame", "",
                "{{Player21}} Item pedestals cycle between 2 options",
                -- Stacks
                "Stacks increase the number of items that can be picked up",
                "en_us"
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

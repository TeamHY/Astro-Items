Astro.Collectible.SCHRODINGERS_CAT = Isaac.GetItemIdByName("Schrodinger's Cat")
Astro.Collectible.GUPPY_PART = Isaac.GetItemIdByName("Guppy Part")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.SCHRODINGERS_CAT,
                "슈뢰딩거의 고양이",
                "살아있으면서 죽어있는",
                "{{Guppy}} 스테이지 진입 시 50%의 확률로 Guppy 세트 +1" ..
                -- 중첩 시
                "추가되는 Guppy 세트가 중첩된 수만큼 +1"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.GUPPY_PART,
                "구피의 조각",
                "How much can one cat take?",    -- https://youtu.be/trUCcvtN1lA
                "!!! {{Collectible" .. Astro.Collectible.SCHRODINGERS_CAT .."}}Schrodinger's Cat의 효과로 획득"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local rng = player:GetCollectibleRNG(Astro.Collectible.SCHRODINGERS_CAT)

            if rng:RandomFloat() < 0.5 then
                for _ = 1, player:GetCollectibleNum(Astro.Collectible.SCHRODINGERS_CAT) do
                    player:AddCollectible(Astro.Collectible.GUPPY_PART)
                end
            end
        end
    end
)

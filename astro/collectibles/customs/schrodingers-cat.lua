Astro.Collectible.SCHRODINGERS_CAT = Isaac.GetItemIdByName("Schrodinger's Cat")
Astro.Collectible.GUPPY_PART = Isaac.GetItemIdByName("Guppy Part")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SCHRODINGERS_CAT,
                "슈뢰딩거의 고양이",
                "살아있으면서 죽어있는",
                "{{Guppy}} 스테이지 진입 시 50%의 확률로 Guppy 세트에 포함됩니다." ..
                "#다음 스테이지 진입 시 효과가 초기화됩니다.",
                -- 중첩 시
                {
                    "Guppy 세트에 포함됩니다.",
                    "Guppy 세트에 중첩된 수만큼 포함됩니다."
                }
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.GUPPY_PART,
                "구피의 조각",
                "How much can one cat take?",    -- https://youtu.be/trUCcvtN1lA
                "!!! {{Collectible" .. Astro.Collectible.SCHRODINGERS_CAT .."}}Schrodinger's Cat의 효과로 획득" ..
                "#다음 스테이지 진입 시 이 아이템은 모두 제거됩니다."
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

            Astro:RemoveAllCollectible(player, Astro.Collectible.GUPPY_PART)

            if rng:RandomFloat() < 0.5 then
                for _ = 1, player:GetCollectibleNum(Astro.Collectible.SCHRODINGERS_CAT) do
                    player:AddCollectible(Astro.Collectible.GUPPY_PART)
                end
            end
        end
    end
)

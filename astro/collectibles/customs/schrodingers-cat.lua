Astro.Collectible.SCHRODINGERS_CAT = Isaac.GetItemIdByName("Schrodinger's Cat")
Astro.Collectible.GUPPY_PART = Isaac.GetItemIdByName("Guppy Part")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SCHRODINGERS_CAT,
        "슈뢰딩거의 고양이",
        "살아있으면서 죽어있는",
        "스테이지 진입 시 50%의 확률로 Guppy 세트 +1;" ..
        "#{{ArrowGrayRight}}다음 스테이지 진입 시 효과는 초기화됩니다." ..
        "#중첩이 가능합니다."
    )
end

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

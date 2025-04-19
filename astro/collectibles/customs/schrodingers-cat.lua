Astro.Collectible.SCHRODINGERS_CAT = Isaac.GetItemIdByName("Schrodinger's Cat")
Astro.Collectible.GUPPY_PART = Isaac.GetItemIdByName("Guppy Part")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SCHRODINGERS_CAT,
        "슈뢰딩거의 고양이",
        "",
        "클리어 되지 않은 방 입장 시 50% 확률로 Guppy 세트 카운트가 1 증가합니다. 방을 나가면 사라집니다. 중첩이 가능합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local room = Game():GetRoom()

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local rng = player:GetCollectibleRNG(Astro.Collectible.SCHRODINGERS_CAT)

            Astro:RemoveAllCollectible(player, Astro.Collectible.GUPPY_PART)

            if not room:IsClear() and rng:RandomFloat() < 0.5 then
                for _ = 1, player:GetCollectibleNum(Astro.Collectible.SCHRODINGERS_CAT) do
                    player:AddCollectible(Astro.Collectible.GUPPY_PART)
                end
            end
        end
    end
)

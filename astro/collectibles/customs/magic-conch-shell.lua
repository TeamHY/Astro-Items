Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIG_CHEST,
                "마법의 소라고동",
                "안돼.",
                "여기에 EID 설명 입력"
            )
        end
    end
)
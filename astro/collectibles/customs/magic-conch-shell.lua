Astro.Collectible.MAGIC_CONCH_SHELL = Isaac.GetItemIdByName("Magic Conch Shell")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.MAGIC_CONCH_SHELL,
                "마법의 소라고동",
                "안 돼.",
                "여기에 EID 설명 입력"
            )
        end
    end
)
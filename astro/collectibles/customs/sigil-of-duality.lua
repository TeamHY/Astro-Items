--[[
Astro.Collectible.SIGIL_OF_DUALITY = Isaac.GetItemIdByName("Sigil of Duality")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SIGIL_OF_DUALITY,
                "이중성의 인장",
                "...",
                "이번 게임에서 {{DevilRoom}}악마방과 {{AngelRoom}}천사방이 등장하지 않습니다." ..
                "#보스방 클리어 시 석상이 등장합니다." ..
                "#석상에게 접촉 시 Uriel 또는 Gabriel이 소환되며 보스 처치 시 이중성의 방으로 이동합니다:" ..
                "#{{ArrowGrayRight}} 이중성의 방에선 체력 거래가 필요한 {{DevilRoom}}악마방 아이템과 {{BrokenHeart}}소지 불가능 체력 거래가 필요한 {{AngelRoom}}천사방 아이템이 존재합니다."
            )
        end
    end
)]]
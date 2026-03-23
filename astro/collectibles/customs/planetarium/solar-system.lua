Astro.Collectible.SOLAR_SYSTEM = Isaac.GetItemIdByName("Solar System")

if EID then
    Astro.EID:AddCollectible(
        Astro.Collectible.SOLAR_SYSTEM,
        "태양계",
        "고향별",
        "!!! 획득 시 소지중인 {{Planetarium}}천체관 관련 아이템을 모두 제거하며;" ..
        "#{{ArrowGrayRight}} 제거한 만큼 {{Planetarium}}천체관 관련 아이템을 소환합니다."
    )
end

local ITEM_ID = Astro.Collectible.SOLAR_SYSTEM

Astro.MegaUI:CreateInstance(
    {
        anm2Path = "gfx/ui/solar-system-ui.anm2",
        choiceCount = 9,
        itemId = ITEM_ID,
        offset = Vector(0, 40),
        onChoiceSelected = function(player, choice)
            local items = {
                Astro.Collectible.SOL_EX,
                Astro.Collectible.LUNA_EX,
                Astro.Collectible.MERCURIUS_EX,
                Astro.Collectible.VENUS_EX,
                Astro.Collectible.MARS_EX,
                Astro.Collectible.JUPITER_EX,
                Astro.Collectible.SATURNUS_EX,
                Astro.Collectible.URANUS_EX,
                Astro.Collectible.NEPTUNUS_EX
            }

            Astro.HiddenItemManager:AddForFloor(player, items[choice])
            SFXManager():Play(910)
        end
    }
)

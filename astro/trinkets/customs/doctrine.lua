Astro.Trinket.DOCTRINE = Isaac.GetTrinketIdByName("Doctrine")

if EID then
    Astro:AddEIDTrinket(
        Astro.Trinket.DOCTRINE,
        "교리",
        "주의 이름은 찬미 받으소서",
        "{{AngelRoom}} 스테이지 진입 시 천사방 확률 +15%" ..
        "#{{CurseCursedSmall}} 저주에 걸리지 않습니다."
    )

    Astro:AddGoldenTrinketDescription(Astro.Trinket.DOCTRINE, "", 15, 2)
end

local angelRoomChance = 0.15

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if not player:HasTrinket(Astro.Trinket.DOCTRINE) then
                break
            end

            local level = Game():GetLevel()

            if player:GetTrinketMultiplier(Astro.Trinket.DOCTRINE) > 1 then
                level:AddAngelRoomChance(angelRoomChance)
            else
                level:AddAngelRoomChance(angelRoomChance * 2)
            end
        end
    end
)

-- 저주 제거 astro/init.lua

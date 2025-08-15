Astro.Trinket.LEFT_FOOT = Isaac.GetTrinketIdByName("The Left Foot")

if EID then
    Astro:AddEIDTrinket(
        Astro.Trinket.LEFT_FOOT,
        "{{RedChest}} 빨간상자 등장 시 30% 확률로 빨간상자가 하나 더 드랍됩니다.#!!! {{LuckSmall}}행운 수치 비례: 행운 70 이상일 때 100% 확률  ({{LuckSmall}}행운 1당 +1%p)",
        "왼발", "어둠의 보상을 거두어들이다"
    )

    Astro:AddGoldenTrinketDescription(Astro.Trinket.LEFT_FOOT, "", 30, 5 / 3)
end

-- 중복 생성하지 않기 위해, 이미 존재하는 빨간 상자를 무시하기 위해 SubType을 사용한다.
local LEFT_FOOT_SUBTYPE = 1000

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if pickup.Variant == PickupVariant.PICKUP_REDCHEST and pickup.SubType ~= LEFT_FOOT_SUBTYPE then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasTrinket(Astro.Trinket.LEFT_FOOT) then
                    local rng = player:GetTrinketRNG(Astro.Trinket.LEFT_FOOT)

                    local per = 0.3

                    if player:GetTrinketMultiplier(Astro.Trinket.LEFT_FOOT) > 1 then
                        per = 0.5
                    end

                    if rng:RandomFloat() < per + player.Luck / 100 then
                        local currentRoom = Game():GetLevel():GetCurrentRoom()

                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_REDCHEST,
                            LEFT_FOOT_SUBTYPE,
                            currentRoom:FindFreePickupSpawnPosition(pickup.Position, 40, true),
                            Vector.Zero,
                            nil
                        )
                    end

                    break
                end
            end

            pickup.SubType = LEFT_FOOT_SUBTYPE
        end
    end
)

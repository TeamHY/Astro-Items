Astro.Collectible.OMEGA_321 = Isaac.GetItemIdByName("Omega 321")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.OMEGA_321,
        "오메가 321",
        "달에 간 시계",
        "{{Slow}} 방 입장 시 모든 적을 일정 시간동안 둔화시킵니다." ..
        "@!!! 지속시간: ({{Collectible" .. Astro.Collectible.OMEGA_321 .."}} 개수 * 8)초"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        local currentRoom = Game():GetLevel():GetCurrentRoom()

        if not currentRoom:IsClear() then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.OMEGA_321) then
                    for _ = 1, player:GetCollectibleNum(Astro.Collectible.OMEGA_321) do
                        player:UseActiveItem(CollectibleType.COLLECTIBLE_HOURGLASS, false, true, false, false)
                    end

                    break
                end
            end
        end
    end
)

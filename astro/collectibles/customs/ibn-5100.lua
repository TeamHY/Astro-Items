Astro.Collectible.IBN_5100 = Isaac.GetItemIdByName("IBN 5100")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.IBN_5100,
        "IBN 5100",
        "최초의 휴대용 컴퓨터",
        "{{TreasureRoom}}보물방 입장 시 IBN 5100 머신을 1개 소환합니다.#{{ArrowGrayRight}} {{Coin}}동전 10개를 소모하여 {{Collectible422}}Glowing Hourglass를 발동합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        local room = Game():GetRoom()
        
        if room:GetType() ~= RoomType.ROOM_TREASURE or not room:IsFirstVisit() then
            return
        end

        if not Astro:HasCollectible(Astro.Collectible.IBN_5100) then
            return
        end

        Astro:SpawnEntity(Astro.Entity.IBN5100, Isaac.GetPlayer().Position)
    end
)

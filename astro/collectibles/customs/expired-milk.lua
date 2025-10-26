local HiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.EXPIRED_MILK = Isaac.GetItemIdByName("Expired Milk")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.EXPIRED_MILK,
        "상한 우유",
        "피부에 양보하세요",
        "{{Collectible330}} 클리어하지 않은 방에 입장 시:" ..
        "#{{ArrowGrayRight}} {{DamageSmall}}공격력 배율 x0.2" ..
        "#{{ArrowGrayRight}} {{TearsSmall}}연사 배율 x5.5" ..
        "#{{ArrowGrayRight}} {{TearsizeSmall}}눈물크기 -0.3" ..
        "#{{ArrowGrayRight}} {{Chargeable}} 충전이 필요한 공격이 충전 없이 자동으로 발사됩니다." ..
        "#!!! 보스방에서는 미발동",
        -- 중첩 시
        "{{Collectible69}}Chocolate Milk 효과 적용"
    )
end

local function IsAvailableRoom()
    local room = Game():GetRoom()
    local roomType = room:GetType()

    if roomType == RoomType.ROOM_BOSS then
        return false
    end

    return not room:IsClear()
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
    if not IsAvailableRoom() then return end

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local expiredMilkCount = player:GetCollectibleNum(Astro.Collectible.EXPIRED_MILK)

            if expiredMilkCount > 0 then
                HiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_SOY_MILK)
            end
            
            if expiredMilkCount > 1 then
                HiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
            end
        end
    end
)

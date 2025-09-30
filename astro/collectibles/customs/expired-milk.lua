local HiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.EXPIRED_MILK = Isaac.GetItemIdByName("Expired Milk")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.EXPIRED_MILK,
        "상한 우유",
        "...",
        "클리어 하지 않은 방에 입장 시 {{Collectible330}}Soy Milk 효과가 적용됩니다. {{BossRoom}}보스방에서는 발동하지 않습니다.",
        "{{Collectible69}}Chocolate Milk 효과도 함께 적용됩니다."
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

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.LUNA_EX = Isaac.GetItemIdByName("LUNA EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.LUNA_EX,
                "초 달",
                "찬란한 축복을 그대에게",
                "{{Timer}} 맵에 {{UltraSecretRoom}} 특급비밀방을 제외한 모든 방의 위치가 표시됩니다." ..
                "#{{Collectible589}} Luna 효과 발동:" ..
                "#{{IND}} 스테이지에 {{SecretRoom}}비밀방과 {{SuperSecretRoom}}일급 비밀방이 1개씩 더 생성됩니다." ..
                "#{{IND}} 비밀방 입장 시 달빛이 생성됩니다." ..
                "#{{IND}} 달빛과 접촉 시 그 스테이지에서 {{HalfSoulHeart}}소울하트 +0.5, {{TearsSmall}}연사(+상한) +0.5" ..
                "#{{IND}}{{Blank}} (첫 달빛은 추가 {{TearsSmall}}+0.5)" ..
                "#{{Collectible76}} X-Ray Vision 효과 발동:" ..
                "#{{IND}}{{SecretRoom}} 비밀방 및 {{SuperSecretRoom}}일급비밀방이 자동으로 열립니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.LUNA_EX,
                "Luna EX", "",
                "{{Timer}} Full mapping effect for the floor" ..
                "#{{Collectible589}} Luna effect applied:" ..
                "#{{IND}} Adds an extra {{SecretRoom}} Secret Room and {{SuperSecretRoom}} Super Secret Room to each floor" ..
                "#{{IND}}{{Timer}} Secret Rooms contain a beam of light that grant for the floor:" ..
                "#{{IND}}↑ {{Tears}} +0.5 Fire rate" ..
                "#{{IND}}↑ {{Tears}} Additional +0.5 Fire rate from the first beam per floor" ..
                "#{{IND}}{{HalfSoulHeart}} Half a Soul Heart" ..
                "#{{Collectible76}} X-Ray Vision effect applied:" ..
                "#{{IND}}{{SecretRoom}} Opens all secret room entrances",
                nil, "en_us"
            )
        end
    end
)

local function DisplaySecretRoom()
    local level = Game():GetLevel()

    for i = 0, 169 do
        local room = level:GetRoomByIdx(i)

        if room.Data then
            if room.Data.Type == RoomType.ROOM_SECRET or room.Data.Type == RoomType.ROOM_SUPERSECRET or room.Data.Type == RoomType.ROOM_ULTRASECRET then
                room.DisplayFlags = room.DisplayFlags | RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON
            end
        end
    end

    level:UpdateVisibility()
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.LUNA_EX) then
            DisplaySecretRoom()
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_LUNA)

        DisplaySecretRoom()

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_LUNA) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_LUNA)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_XRAY_VISION)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_BLUE_MAP)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    Astro.Collectible.LUNA_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_LUNA) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_LUNA)
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_XRAY_VISION)
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_BLUE_MAP)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    Astro.Collectible.LUNA_EX
)

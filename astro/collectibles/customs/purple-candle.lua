local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.PURPLE_CANDLE = Isaac.GetItemIdByName("Purple Candle")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.PURPLE_CANDLE,
                "보라 양초",
                "저주 면역 + 개안",
                "!!! 획득 이후 {{Collectible260}}Black Candle 미등장" ..
                "#↑ {{DevilChanceSmall}}악마방 확률 +15%" ..
                "#{{CurseCursedSmall}} 스테이지에 입장할 때 저주에 걸리지 않습니다." ..
                "#{{CurseCursedSmall}} 획득 시 Labyrinth/챌린지/특수 시드를 제외한 모든 저주를 제거합니다." ..
                "#{{CurseBlindSmall}} 가려진 아이템을 볼 수 있습니다." ..
                "#방 입장 시 보라색 모닥불이 자동으로 꺼집니다."
            )
            
            Astro:AddEIDCollectible(
                Astro.Collectible.PURPLE_CANDLE,
                "Purple Candle",
                "",
                "!!! {{Collectible260}} Black Candle doesn't appear after pickup" ..
                "#{{CurseBlind}} Immune to curses" ..
                "#↑ {{DevilChance}} +15% Devil/Angel Room chance" ..
                "#{{CurseBlind}} Reveals blind items" ..
                "#Automatically extinguishes purple fire places on room entry",
                nil, "en_us"
            )
        end

        Astro:AddRerollCondition(
            function(selectedCollectible)
                if Astro:HasCollectible(Astro.Collectible.PURPLE_CANDLE) then
                    return {
                        reroll = selectedCollectible == CollectibleType.COLLECTIBLE_BLACK_CANDLE,
                        modifierName = "Purple Candle"
                    }
                end
        
                return false
            end
        )
    end
)




Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.PURPLE_CANDLE) then
            local fires = Isaac.FindByType(EntityType.ENTITY_FIREPLACE, 3)
            
            for _, fire in ipairs(fires) do
                fire:Kill()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro:HasCollectible(Astro.Collectible.PURPLE_CANDLE) then
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local game = Game()
                local roomType = game:GetRoom():GetType()
                local stageType = game:GetLevel():GetStageType()

                if roomType == RoomType.ROOM_TREASURE and stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B then
                    pickup:GetData().ShowBlind = true
                end
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_BLACK_CANDLE)
        end
    end,
    Astro.Collectible.PURPLE_CANDLE
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_BLACK_CANDLE)
        end
    end,
    Astro.Collectible.PURPLE_CANDLE
)

---

local UPGRADE_CHANCE = 0.5

---

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
                "...",
                "{{Collectible260}} Black Candle 효과가 적용됩니다." ..
                "#{{CurseBlindSmall}} 가려진 아이템을 알 수 있게 됩니다." ..
                "#방 입장 시 보라색 모닥불이 자동으로 꺼집니다." ..
                "#!!! 소지중일 때 {{Collectible260}}Black Candle이 등장하지 않습니다."
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
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        if selectedCollectible == CollectibleType.COLLECTIBLE_BLACK_CANDLE then
            local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.PURPLE_CANDLE)

            if rng:RandomFloat() < UPGRADE_CHANCE then
                return Astro.Collectible.PURPLE_CANDLE
            end
        end
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

local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.MARS_EX = Isaac.GetItemIdByName("MARS EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.MARS_EX,
        "초 화성",
        "...",
        "{{Collectible593}}Mars 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#방 마다 1번씩 패널티 피격 시 돌진하여 접촉한 적에게 공격력 x4 +8의 피해를 입힙니다. 중첩 시 횟수가 증가합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.MARS_EX) then
                local data = player:GetData()

                if data.AstroMarsEX == nil then
                    data.AstroMarsEX = {
                        Count = 0
                    }
                end

                data.AstroMarsEX.Count = player:GetCollectibleNum(AstroItems.Collectible.MARS_EX)
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = entity:ToPlayer()

        if player:HasCollectible(AstroItems.Collectible.MARS_EX) then
            local data = player:GetData()

            if data.AstroMarsEX.Count > 0 and damageFlags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS) == 0 then
                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MARS)
                data.AstroMarsEX.Count = data.AstroMarsEX.Count - 1

                return false
            end
        end
    end,
    EntityType.ENTITY_PLAYER
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_MARS)

        local data = player:GetData()

        if data.AstroMarsEX == nil then
            data.AstroMarsEX = {
                Count = 0
            }
        end

        data.AstroMarsEX.Count = player:GetCollectibleNum(AstroItems.Collectible.MARS_EX)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MARS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_MARS)
        end
    end,
    AstroItems.Collectible.MARS_EX
)

-- AstroItems:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MARS) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_MARS)
--         end
--     end,
--     AstroItems.Collectible.MARS_EX
-- )

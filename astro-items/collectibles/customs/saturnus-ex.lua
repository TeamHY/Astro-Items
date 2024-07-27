---

local COOLDOWN = 300

---

local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.SATURNUS_EX = Isaac.GetItemIdByName("SATURNUS EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.SATURNUS_EX,
        "초 토성",
        "...",
        EID:getDescriptionObj(5, 100, CollectibleType.COLLECTIBLE_SATURNUS, nil, false).Description ..
        "#10초 마다 {{Collectible522}}Telekinesis를 1회 발동합니다. 중첩 시 횟수가 늘어납니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if Game():GetFrameCount() % COOLDOWN == 0 then
            if player:HasCollectible(AstroItems.Collectible.SATURNUS_EX) then
                for _ = 1, player:GetCollectibleNum(AstroItems.Collectible.SATURNUS_EX) do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, false, true, false, false)
                end
            end
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SATURNUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SATURNUS)
        end
    end,
    AstroItems.Collectible.SATURNUS_EX
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SATURNUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SATURNUS)
        end
    end,
    AstroItems.Collectible.SATURNUS_EX
)

---

local COOLDOWN = 300

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SATURNUS_EX = Isaac.GetItemIdByName("SATURNUS EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SATURNUS_EX,
        "초 토성",
        "눈물 방어막",
        "{{Collectible595}} Saturnus 효과가 적용됩니다." ..
        "#10초마다 {{Collectible522}}Telekinesis를 1회 발동합니다." ..
        "#{{ArrowGrayRight}} 중첩 시 횟수가 늘어납니다." ..
        "#!!! 이번 게임에서 {{Collectible595}}Saturnus가 등장하지 않습니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if Game():GetFrameCount() % COOLDOWN == 0 then
            if player:HasCollectible(Astro.Collectible.SATURNUS_EX) then
                for _ = 1, player:GetCollectibleNum(Astro.Collectible.SATURNUS_EX) do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, false, true, false, false)
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
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SATURNUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SATURNUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SATURNUS)
        end
    end,
    Astro.Collectible.SATURNUS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SATURNUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SATURNUS)
        end
    end,
    Astro.Collectible.SATURNUS_EX
)

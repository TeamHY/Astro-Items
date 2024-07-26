---

-- 중첩 시 0.5 -> 0.75 -> 0.875
local SOUL_CAIN_CHANCE = 0.5

---

local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.MERCURIUS_EX = Isaac.GetItemIdByName("MERCURIUS EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.MERCURIUS_EX,
        "초 수성",
        "...",
        EID:getDescriptionObj(5, 100, CollectibleType.COLLECTIBLE_MERCURIUS, nil, false).Description ..
            "#방 클리어 시 50% 확률로 {{Card83}}Soul of Cain을 발동합니다."
    )
end

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.MERCURIUS_EX) then
                local rng = player:GetCollectibleRNG(AstroItems.Collectible.MERCURIUS_EX)

                if rng:RandomFloat() < 1 - ((1 - SOUL_CAIN_CHANCE) ^ player:GetCollectibleNum(AstroItems.Collectible.MERCURIUS_EX)) then
                    player:UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
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
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MERCURIUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_MERCURIUS)
        end
    end,
    AstroItems.Collectible.MERCURIUS_EX
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MERCURIUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_MERCURIUS)
        end
    end,
    AstroItems.Collectible.MERCURIUS_EX
)

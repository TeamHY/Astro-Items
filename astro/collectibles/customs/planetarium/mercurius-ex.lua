---

-- 중첩 시 0.5 -> 0.75 -> 0.875
local SOUL_CAIN_CHANCE = 0.5

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.MERCURIUS_EX = Isaac.GetItemIdByName("MERCURIUS EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.MERCURIUS_EX,
        "초 수성",
        "...",
        "{{Collectible590}} Mercurius 효과가 적용됩니다." ..
        "#방 클리어 시 50% 확률로 {{Card83}}Soul of Cain을 발동합니다." ..
        "#!!! 이번 게임에서 {{Collectible590}}Mercurius가 등장하지 않습니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.MERCURIUS_EX) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.MERCURIUS_EX)

                if rng:RandomFloat() < 1 - ((1 - SOUL_CAIN_CHANCE) ^ player:GetCollectibleNum(Astro.Collectible.MERCURIUS_EX)) then
                    player:UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
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
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_MERCURIUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MERCURIUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_MERCURIUS)
        end
    end,
    Astro.Collectible.MERCURIUS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_MERCURIUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_MERCURIUS)
        end
    end,
    Astro.Collectible.MERCURIUS_EX
)

---

local COOLDOWN = 150

---

local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.JUPITER_EX = Isaac.GetItemIdByName("JUPITER EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.JUPITER_EX,
        "초 목성",
        "...",
        "{{Collectible594}}Jupiter 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#{{Collectible180}}Black Bean 효과가 적용됩니다." ..
        "#5초 마다 {{Collectible486}}Dull Razor를 1회 발동합니다. 중첩 시 횟수가 늘어납니다." ..
        "#최초 획득 시 {{Card71}}XV - The Devil?를 발동합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if Game():GetFrameCount() % COOLDOWN == 0 then
            if player:HasCollectible(Astro.Collectible.JUPITER_EX) then
                for _ = 1, player:GetCollectibleNum(Astro.Collectible.JUPITER_EX) do
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false, true, false, false)
                    SFXManager():Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
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
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_JUPITER)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_JUPITER) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_JUPITER)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_BLACK_BEAN)

            player:UseCard(Card.CARD_REVERSE_DEVIL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end
    end,
    Astro.Collectible.JUPITER_EX
)

-- Astro:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_JUPITER) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_JUPITER)
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_BLACK_BEAN)
--         end
--     end,
--     Astro.Collectible.JUPITER_EX
-- )

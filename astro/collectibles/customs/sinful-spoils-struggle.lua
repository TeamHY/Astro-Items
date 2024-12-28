local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SINFUL_SPOILS_STRUGGLE = Isaac.GetItemIdByName("Sinful Spoils Struggle")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SINFUL_SPOILS_STRUGGLE,
                "죄보합전",
                "...",
                "{{Collectible684}}Hungry Soul 효과가 적용됩니다." ..
                "{{Collectible634}}Purgatory 효과가 적용됩니다." ..
                "중첩 시 {{Collectible727}}Ghost Bombs 효과가 적용됩니다." ..
                "소환된 유령의 속도가 2배 빨라집니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.SINFUL_SPOILS_STRUGGLE) then
            local effects = Isaac.FindByType(EntityType.ENTITY_EFFECT)

            for _, entity in ipairs(effects) do
                if entity.Variant == EffectVariant.PURGATORY or entity.Variant == EffectVariant.HUNGRY_SOUL then
                    entity:Update()
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
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_HUNGRY_SOUL) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_HUNGRY_SOUL)
        end

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_PURGATORY) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_PURGATORY)
        end

        if player:GetCollectibleNum(Astro.Collectible.SINFUL_SPOILS_STRUGGLE) > 1 then
            if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_GHOST_BOMBS) then
                hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_GHOST_BOMBS)
            end
        end
    end,
    Astro.Collectible.SINFUL_SPOILS_STRUGGLE
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_HUNGRY_SOUL) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_HUNGRY_SOUL)
        end

        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_PURGATORY) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_PURGATORY)
        end

        if player:GetCollectibleNum(Astro.Collectible.SINFUL_SPOILS_STRUGGLE) <= 1 then
            if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_GHOST_BOMBS) then
                hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_GHOST_BOMBS)
            end
        end
    end,
    Astro.Collectible.SINFUL_SPOILS_STRUGGLE
)

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_EVE = Isaac.GetItemIdByName("Birthright - Eve")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.BIRTHRIGHT_EVE,
                "이브의 생득권",
                "영원한 저주",
                "{{Collectible122}} {{Collectible117}} Whore of Babylon과 Dead Bird의 효과가 항상 발동됩니다.",
                -- 중첩 시
                "중첩된 수만큼 발동"
            )
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local targetNum = player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_EVE)
        local effectNum = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON)

        if targetNum > effectNum then
            local additionalEffects = targetNum - effectNum

            player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, true, additionalEffects)
            player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_DEAD_BIRD, true, additionalEffects)
        end
    end,
    Astro.Collectible.BIRTHRIGHT_EVE
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            local targetNum = player:GetCollectibleNum(Astro.Collectible.BIRTHRIGHT_EVE)
            local effectNum = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON)

            if targetNum > effectNum then
                local additionalEffects = targetNum - effectNum

                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, true, additionalEffects)
                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_DEAD_BIRD, true, additionalEffects)
            end
        end
    end
)

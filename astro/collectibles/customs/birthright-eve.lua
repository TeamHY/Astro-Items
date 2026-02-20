local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_EVE = Isaac.GetItemIdByName("Eve's Frame")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_EVE,
                "이브의 액자",
                "영원한 저주",
                "{{Collectible122}} Whore of Babylon 효과 발동:" ..
                "#{{IND}}↑ {{DamageSmall}}공격력 +1.5" ..
                "#{{IND}}↑ {{SpeedSmall}}이동속도 +0.3" ..
                "#{{Collectible117}} 적을 따라다니며 접촉한 적에게 초당 4.3의 피해를 주는 Dead Bird 패밀리어를 얻습니다.",
                -- 중첩 시
                "중첩된 수만큼 발동"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.BIRTHRIGHT_EVE,
                "Eve's Frame", "",
                "{{Collectible122}} Whore of Babylon effect applied:" ..
                "#{{IND}}↑ {{Damage}} +1.5 Damage" ..
                "#{{IND}}↑ {{Speed}} +0.3 Speed" ..
                "#{{Collectible117}} Grants a Dead Bird familiar that deals 4.3 contact damage per second",
                -- Stacks
                "Stackable",
                "en_us"
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

            for _ = 1, targetNum do
                player:UseCard(Card.CARD_EMPRESS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            end
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

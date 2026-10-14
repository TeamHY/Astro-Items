Astro.Collectible.ASTRO_SACRED_HEART = Isaac.GetItemIdByName("Astro Sacred Heart")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ASTRO_SACRED_HEART,
                "광휘로운 심장",
                "유도 공격 + 추가 피해",
                "방 입장 시 {{Card2}}I - The Magician이 발동됩니다." ..
                "#적이 받는 피해량이 2.3배로 증가합니다.",
                -- 중첩 시
                "중첩 시 적이 받는 피해량이 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.ASTRO_SACRED_HEART,
                "Astro Sacred Heart",
                "",
                "Uses {{Card2}}I - The Magician when entering a room" ..
                "#{{Damage}} Damage to enemies increases by 2.3x on hit",
                -- Stacks
                "Stacks increase extra damage",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        if entity:IsVulnerableEnemy() and source.Entity ~= nil and damageFlags & DamageFlag.DAMAGE_IV_BAG == 0 then
            local player = Astro:GetPlayerFromEntity(source.Entity)
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.ASTRO_SACRED_HEART) then
                local numAstroSacredHeart = player:GetCollectibleNum(Astro.Collectible.ASTRO_SACRED_HEART)
                entity:TakeDamage(amount * ((2.3 * numAstroSacredHeart) - 1), damageFlags | DamageFlag.DAMAGE_IV_BAG, source, countdownFrames)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.ASTRO_SACRED_HEART) then
                player:UseCard(Card.CARD_MAGICIAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOCOSTUME)
            end
        end
    end
)

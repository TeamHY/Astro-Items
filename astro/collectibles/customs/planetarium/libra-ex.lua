Astro.Collectible.LIBRA_EX = Isaac.GetItemIdByName("Libra EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            EID:assignTransformation("collectible", Astro.Collectible.LIBRA_EX, "Chubby")
            
            Astro:AddEIDCollectible(
                Astro.Collectible.LIBRA_EX,
                "초 천칭자리",
                "공평하게",
                "적에게 준 피해의 10%만큼 그 방의 다른 적에게 피해를 줍니다.",
                -- 중첩 시
                "중첩 시 적에게 주는 피해량이 중첩된 수만큼 합연산으로 증가"
            )

            Astro:AddEIDCollectible(
                Astro.Collectible.LIBRA_EX,
                "Libra EX",
                "",
                "Deals 10% damage given to enemies to all enemies in the room",
                -- Stacks
                "Increases damage dealt to all enemies in the room when stacked",
                "en_us"
            )
        end
    end
)


------ 기존 초 게자리 -----
Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if player ~= nil and player:HasCollectible(Astro.Collectible.LIBRA_EX) and entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
            if
                source.Type == EntityType.ENTITY_TEAR or
                damageFlags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER or
                source.Type == EntityType.ENTITY_KNIFE
            then
                local entities = Isaac.GetRoomEntities()

                for i = 1, #entities do
                    if entities[i]:IsVulnerableEnemy() and entities[i].Type ~= EntityType.ENTITY_FIREPLACE and not (entities[i].Type == EntityType.ENTITY_MAMA_GURDY and entities[i].Variant > 0) then
                        entities[i]:TakeDamage(amount / 10 * player:GetCollectibleNum(Astro.Collectible.LIBRA_EX), 0, EntityRef(player), 1)
                    end
                end
            end
        end
    end
)


------ 처비셋 ------
Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if collectibleType == Astro.Collectible.LIBRA_EX and Astro:IsFirstAdded(collectibleType) then
            Astro.Data.ChubbySet = Astro.Data.ChubbySet + 1

            if Astro.Data.ChubbySet == 3 then
                local Flavor
                if Options.Language == "kr" or REPKOR then
                    Flavor = "처비!!!"
                else
                    Flavor = "Chubby!!!"
                end

                SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
                Game():GetHUD():ShowItemText(Flavor)
            end
        end
    end
)

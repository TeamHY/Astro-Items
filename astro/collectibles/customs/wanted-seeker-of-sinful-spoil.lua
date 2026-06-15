Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL = Isaac.GetItemIdByName("WANTED: Seeker of Sinful Spoil")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL,
                "죄보사냥의 악마",
                "\"죄보\"를 둘러싼 이야기를 쫓는 당신에게",
                "!!! 일회용 !!!" ..
                "#사용 시:" ..
                "#{{IND}}{{Player" .. Astro.Players.DIABELLSTAR .. "}} 캐릭터를 Diabellstar로 변경합니다." ..
                "#{{IND}}그 방의 아이템을 {{Collectible" .. Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE .. "}} 또는 {{Collectible" .. Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE .. "}}으로 바꿉니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL,
                "WANTED: Seeker of Sinful Spoil", "",
                "!!! SINGLE USE !!!" ..
                "#{{Player" .. Astro.Players.DIABELLSTAR .. "}} Changes character to Diabellstar",
                nil, "en_us"
            )

            Astro.EID:RegisterAlternativeText(
                { itemType = ItemType.ITEM_ACTIVE, subType = Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL },
                "WANTED: Seeker of S.S."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        playerWhoUsedItem:ChangePlayerType(Astro.Players.DIABELLSTAR)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, playerWhoUsedItem.Position, Vector.Zero, playerWhoUsedItem):ToEffect()
        effect:FollowParent(playerWhoUsedItem)
        effect.Color = Color(0, 0, 0, 1, 1, 0, 0)

        local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        for _, entity in ipairs(items) do
            if entity.SubType ~= 0 and entity.SubType < 4294960000 then
                local item = entity:ToPickup()
                local nextid, particleSubType

                if rngObj:RandomFloat() < 0.5 then
                    nextid = Astro.Collectible.SINFUL_SPOILS_OF_SUBVERSION_SNAKE_EYE
                    particleSubType = 1
                else
                    nextid = Astro.Collectible.ORIGINAL_SINFUL_SPOILS_SNAKE_EYE
                    particleSubType = 2
                end

                if item then
                    Game():SpawnParticles(item.Position, EffectVariant.ENEMY_GHOST, 1, 0, nil, nil, particleSubType)
                    item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, nextid, true)
                    item.Touched = false
                end
            end
        end
        
        SFXManager():Play(910)

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL
)

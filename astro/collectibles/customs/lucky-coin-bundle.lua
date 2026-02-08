Astro.Collectible.LUCKY_COIN_BUNDLE = Isaac.GetItemIdByName("Lucky Coin Bundle")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.LUCKY_COIN_BUNDLE,
                "행운의 동전 번들",
                "운칠기삼",
                "{{Crafting11}} 행운 동전 픽업이 1+1로 나옵니다." ..
                "#{{Crafting11}} 1+1 행운 동전 1개를 드랍합니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.LUCKY_COIN_BUNDLE,
                "Lucky Penny Bundle", "",
                "{{Crafting11}} All Lucky penny drops become Double Lucky pennies" ..
                "#{{Crafting11}} Spawns Double Lucky pennies",
                nil, "en_us"
            )

            Astro.EID:RegisterAlternativeText(
                { itemType = ItemType.ITEM_PASSIVE, subType = Astro.Collectible.LUCKY_COIN_BUNDLE },
                "Lucky Penny Bundle"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro:HasCollectible(Astro.Collectible.LUCKY_COIN_BUNDLE) and pickup.SubType == 5 then
            if Astro.Data["AltLuckyPennyColor"] == 1 then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 3101, true, true, false)
            else
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 3100, true, true, false)
            end
            
            local sprite = pickup:GetSprite()
            sprite:Play("Appear", true)
        end
    end,
    PickupVariant.PICKUP_COIN
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_PICKUP_COLLISION,
    ---@param pickup EntityPickup
    ---@param collider Entity
    ---@param low boolean
    function(_, pickup, collider, low)
        local player = collider:ToPlayer()

        if player and pickup.SubType == 3101 or pickup.SubType == 3100 then
            if pickup.Wait > 0 then
                return true
            end
            
            local sprite = pickup:GetSprite()

            if sprite:IsPlaying("Appear") then
                return true
            end

            sprite:Play("Collect", true)
            SFXManager():Play(SoundEffect.SOUND_LUCKYPICKUP, 1)

            local data = Astro.SaveManager.GetRunSave(player)
            data["doubleLuckyPennyLuck"] = data["doubleLuckyPennyLuck"] or 0
            data["doubleLuckyPennyLuck"] = data["doubleLuckyPennyLuck"] + 2

            player:AddCoins(2)
            player:AnimateHappy()
            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            player:EvaluateItems()

            if Options.Language == "kr" then
                Game():GetHUD():ShowItemText("행운의 동전 x2", "행운 증가 x2", false, false)
            else
                Game():GetHUD():ShowItemText("Lucky Penny x2", "Luck up x2", false, false)
            end
        end
    end,
    PickupVariant.PICKUP_COIN
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    ---@param pickup EntityPickup
    function(_, pickup)
        if pickup.SubType == 3101 or pickup.SubType == 3100 then
            local sprite = pickup:GetSprite()

            if sprite:IsEventTriggered("DropSound") then
                SFXManager():Play(SoundEffect.SOUND_PENNYDROP, 1)
            end

            if sprite:IsFinished("Appear") then
                sprite:Play("Idle", true)
            elseif sprite:IsFinished("Collect") then
                pickup:Remove()
            end
        end
    end,
    PickupVariant.PICKUP_COIN
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data =  Astro.SaveManager.GetRunSave(player)
        if data["doubleLuckyPennyLuck"] and data["doubleLuckyPennyLuck"] > 0 then
            player.Luck = player.Luck + data["doubleLuckyPennyLuck"]
        end
    end,
    CacheFlag.CACHE_LUCK
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.LUCKY_COIN_BUNDLE) then
            if Astro.Data["AltLuckyPennyColor"] == 1 then
                Astro:Spawn(5, 20, 3101, player.Position)
            else
                Astro:Spawn(5, 20, 3100, player.Position)
            end
        end
    end,
    Astro.Collectible.LUCKY_COIN_BUNDLE
)
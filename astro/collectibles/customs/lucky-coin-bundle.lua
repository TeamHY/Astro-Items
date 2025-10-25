Astro.Collectible.LUCKY_COIN_BUNDLE = Isaac.GetItemIdByName("Lucky Coin Bundle")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.LUCKY_COIN_BUNDLE,
        "행운 동전 번들",
        "운칠기삼",
        "{{Crafting11}} 행운 동전이 픽업이 1+1로 나옵니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro:HasCollectible(Astro.Collectible.LUCKY_COIN_BUNDLE) and pickup.SubType == 5 then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 3100, true, true, false)
            
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

        if player and pickup.SubType == 3100 then
            if pickup.Wait > 0 then
                return true
            end
            
            local sprite = pickup:GetSprite()

            if sprite:IsPlaying("Appear") then
                return true
            end

            sprite:Play("Collect", true)
            SFXManager():Play(SoundEffect.SOUND_LUCKYPICKUP, 1)

            player:AddCoins(2)

            local data =  Astro.SaveManager.GetRunSave(player)
            data["doubleLuckyPennyLuck"] = data["doubleLuckyPennyLuck"] or 0
            data["doubleLuckyPennyLuck"] = data["doubleLuckyPennyLuck"] + 2

            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            player:EvaluateItems()
        end
    end,
    PickupVariant.PICKUP_COIN
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    ---@param pickup EntityPickup
    function(_, pickup)
        if pickup.SubType == 3100 then
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

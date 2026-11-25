local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.AI_GLASSES = Isaac.GetItemIdByName("AI Glasses")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.AI_GLASSES,
                "AI 안경",
                "브레인 악셀",
                "공격이 2발로 나갑니다." ..
                "#공격이 적이 있는 방향을 향해 직선으로 날아갑니다." ..
                "#{{TreasureRoom}} 리펜턴스 추가 스테이지 보물방의 가려진 아이템을 볼 수 있습니다." ..
                "#{{SecretRoom}} 비밀방 및 {{SuperSecretRoom}}일급비밀방이 자동으로 열립니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.AI_GLASSES,
                "AI Glasses", "",
                "Isaac shoots 2 tears at once" ..
                "#Tears turn 90 degrees to target enemies that they may have missed" ..
                "#Reveal the blind item in alt path Treasure Rooms" ..
                "{{SecretRoom}} Opens all secret room entrances",
                nil, "en_us"
            )
        end
    end
)

local PARTICLE_VARIANT = Isaac.GetEntityVariantByName("AI Glasses Particles")

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.AI_GLASSES) then
            local rng = player:GetCollectibleRNG(Astro.Collectible.AI_GLASSES)
            local temporacyEffect = player:GetEffects()

            if not temporacyEffect:HasCollectibleEffect(CollectibleType.COLLECTIBLE_20_20) then
                temporacyEffect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_20_20, false, 1)
            end

            if player:IsFrame(rng:RandomInt(180) + 2, 0) then
                for i = 1, rng:RandomInt(5) + 2 do
                    local particle = Isaac.Spawn(1000, PARTICLE_VARIANT, 0, player.Position, Vector.Zero, player):ToEffect()
                    particle:FollowParent(player)
                    particle.SpriteOffset = RandomVector() * 75
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro:HasCollectible(Astro.Collectible.AI_GLASSES) then
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local game = Game()
                local roomType = game:GetRoom():GetType()
                local stageType = game:GetLevel():GetStageType()

                if roomType == RoomType.ROOM_TREASURE and stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B then
                    pickup:GetData().ShowBlind = true
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.AI_GLASSES) then
            if cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_TURN_HORIZONTAL
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.AI_GLASSES) then
            return
        end

        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_XRAY_VISION, 1, "ASTRO_AI_GLASSES")
        player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_XRAY_VISION))
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    ---@param effect EntityEffect
    function(_, effect)
        local sprite = effect:GetSprite()
        local rng = effect:GetDropRNG()
        sprite:Play("particle" .. tostring(rng:RandomInt(26) + 1), true)
        effect.ParentOffset = Vector(0, -50)
    end,
    PARTICLE_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    ---@param renderOffset Vector
    function(_, effect, renderOffset)
        local offset = effect.SpriteOffset
        local distance = offset:Length()
        effect.SpriteOffset = offset - offset:Resized(2.5)
        effect.DepthOffset = -100

        if effect.FrameCount > 30 then
            effect:Remove()
        end
    end,
    PARTICLE_VARIANT
)
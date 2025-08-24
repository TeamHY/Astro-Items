Astro.Collectible.STEAM_BUNDLE = Isaac.GetItemIdByName("Steam Bundle")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.STEAM_BUNDLE,
                "스팀 번들",
                "사장님이 미쳤어요",
                "{{Collectible203}} {{Heart}}빨간하트, {{Coin}}동전, {{Bomb}}폭탄, {{Key}}열쇠 픽업이 1+1로 나옵니다.",
                -- 중첩 시
                "스테이지 진입 시 {{GoldenKey}}황금 열쇠와 {{GoldenBomb}}황금 폭탄 소환"
            )
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        local steamBundleCount = Astro:GetCollectibleNum(Astro.Collectible.STEAM_BUNDLE)
            
        if steamBundleCount >= 2 then
            local position = Isaac.GetPlayer().Position
            
            Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 2, position)
            Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 4, position)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro:HasCollectible(Astro.Collectible.STEAM_BUNDLE) then
            if pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == 1 then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 5, true)
            elseif pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == 1 then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 4, true)
            elseif pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType == 1 then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 3, true)
            elseif pickup.Variant == PickupVariant.PICKUP_BOMB and pickup.SubType == 1 then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 2, true)
            end
        end
    end
)

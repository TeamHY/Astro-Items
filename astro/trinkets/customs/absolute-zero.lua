Astro.Trinket.ABSOLUTE_ZERO = Isaac.GetTrinketIdByName("Absolute Zero")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddTrinket(
                Astro.Trinket.ABSOLUTE_ZERO,
                "절대 영도", "-273.15도",
                "{{Freezing}} 공격 시 10%의 확률로 적이 얼어붙는 눈물이 나갑니다." ..
                "#{{ArrowGrayRight}} 얼어붙은 적은 접촉 시 직선으로 날아가 10방향으로 고드름 눈물을 발사합니다." ..
                "#{{LuckSmall}} 행운 45 이상일 때 100% 확률 (행운 1당 +2%p)"
            )

            Astro.EID:AddTrinket(
                Astro.Trinket.ABSOLUTE_ZERO,
                "Absolute Zero",
                "",
                "{{Freezing}} Isaac has a 10% chance to shoot petrifying tears that freeze enemies on death" ..
                "#{{ArrowGrayRight}} Touching a frozen enemy makes it slide away and explode into 10 ice shards" ..
                "#{{Luck}} 100% chance to at 45 Luck (+2%p per Luck)",
                nil, "en_us"
            )

            Astro:AddGoldenTrinketDescription(Astro.Trinket.ABSOLUTE_ZERO, "", 10, 2)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)

        if player ~= nil then
            if
                player:HasTrinket(Astro.Trinket.ABSOLUTE_ZERO) and
                    not player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS)
             then
                local rng = player:GetTrinketRNG(Astro.Trinket.ABSOLUTE_ZERO)

                if rng:RandomFloat() < 0.1 * player:GetTrinketMultiplier(Astro.Trinket.ABSOLUTE_ZERO) + player.Luck / 50 then
                    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_ICE
                    tear:ChangeVariant(TearVariant.ICE)
                end
            end
        end
    end
)

Astro.Collectible.LIFE_SUSTAINING_TREATMENT = Isaac.GetItemIdByName("Life-Sustaining Treatment")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_EUTHANASIA].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible496}}{{ColorYellow}}안락사{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible496}} {{ColorYellow}}Euthanasia{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.LIFE_SUSTAINING_TREATMENT, CRAFT_HINT)

            Astro.EID:AddCollectible(
                Astro.Collectible.LIFE_SUSTAINING_TREATMENT,
                "연명치료",
                "이토록 시린 아픔만이",
                "확률적으로 공격력 x3의 적을 즉사시키며 눈물이 10방향으로 퍼지는 공격이 나갑니다." ..
                "#{{LuckSmall}} 행운 14.5 이상일 때 100% 확률"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.LIFE_SUSTAINING_TREATMENT,
                "Life-Sustaining Treatment",
                "",
                "Chance to shoot a needle" ..
                "#{{Luck}} 100% chance at 14.5 luck" ..
                "#Needles kill normal enemies instantly, bursting them into 10 tears" ..
                "#{{Damage}} Needles deal 3x Isaac's damage against bosses",
                nil, "en_us"
            )

            Astro.EID.LuckFormulas["5.100." .. tostring(Astro.Collectible.LIFE_SUSTAINING_TREATMENT)] = function(luck, num)
                local denominator = 30 - math.floor(luck * 2)
                local chance = denominator <= 0 and 1 or (1 / denominator)

                return chance * 100
            end
        end
    end
)

local function CheckNeedleChance(player)
    local rng = player:GetCollectibleRNG(Astro.Collectible.LIFE_SUSTAINING_TREATMENT)
    local denominator = 30 - math.floor(player.Luck * 2)
    local chance = denominator <= 0 and 1 or (1 / denominator)
    
    return rng:RandomFloat() < chance
end

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        
        if player ~= nil and player:HasCollectible(Astro.Collectible.LIFE_SUSTAINING_TREATMENT) then
            if CheckNeedleChance(player) then
                tear:ChangeVariant(TearVariant.NEEDLE)
                tear:AddTearFlags(TearFlags.TEAR_NEEDLE)
                tear.CollisionDamage = tear.CollisionDamage * 3
            end
        end
    end
)

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_TECH_LASER,
        ---@param laser EntityLaser
        function(_, laser)
            local player = Astro:GetPlayerFromEntity(laser)
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.LIFE_SUSTAINING_TREATMENT) then
                if CheckNeedleChance(player) then
                    laser:AddTearFlags(TearFlags.TEAR_NEEDLE)
                    laser.CollisionDamage = laser.CollisionDamage * 3
                end
            end
        end
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_TECH_X_LASER,
        ---@param laser EntityLaser
        function(_, laser)
            local player = Astro:GetPlayerFromEntity(laser)
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.LIFE_SUSTAINING_TREATMENT) then
                if CheckNeedleChance(player) then
                    laser:AddTearFlags(TearFlags.TEAR_NEEDLE)
                    laser.CollisionDamage = laser.CollisionDamage * 3
                end
            end
        end
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL,
        ---@param laser EntityLaser
        function(_, laser)
            local player = Astro:GetPlayerFromEntity(laser)
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.LIFE_SUSTAINING_TREATMENT) then
                if CheckNeedleChance(player) then
                    laser:AddTearFlags(TearFlags.TEAR_NEEDLE)
                    laser.CollisionDamage = laser.CollisionDamage * 3
                end
            end
        end
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_FIRE_SWORD,
        ---@param knife EntityKnife
        function(_, knife)
            local player = Astro:GetPlayerFromEntity(knife)
            
            if player ~= nil and player:HasCollectible(Astro.Collectible.LIFE_SUSTAINING_TREATMENT) then
                if CheckNeedleChance(player) then
                    knife:AddTearFlags(TearFlags.TEAR_NEEDLE)
                    knife.CollisionDamage = knife.CollisionDamage * 3
                end
            end
        end
    )
end

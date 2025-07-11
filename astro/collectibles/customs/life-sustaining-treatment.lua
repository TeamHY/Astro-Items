local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.LIFE_SUSTAINING_TREATMENT = Isaac.GetItemIdByName("Life-Sustaining Treatment")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.LIFE_SUSTAINING_TREATMENT,
        "연명치료",
        "",
        "확률적으로 적을 즉사시키는 바늘 눈물을 발사합니다. 해당 적이 죽을 때 주변에 눈물이 퍼집니다." ..
        "#보스에게는 3배 데미지를 줍니다." ..
        "#!!! {{LuckSmall}}행운 수치 비례: 행운 14.5 이상일 때 100% 확률"
    )
end

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

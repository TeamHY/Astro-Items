Astro.Collectible.PISCES_EX = Isaac.GetItemIdByName("Pisces EX")

---

local SPAWN_CHANCE = 0.05    -- 기본 소환 확률

local MAX_CHANCE = 0.2    -- 최대 소환 확률

local LUCK_MULTIPLY = 1 / 100    -- 행운 1당 몇 %p으로 할진

local COOLDOWN_TIME = 15    -- 30 프레임 = 1초

local TEARS_INCREMENT = 0.5    -- 연사 상한 증가량

local WATER_SPLASH_VARIANT = 3112

---

local PISCES_EX_VARIANT = 3114

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.PISCES_EX,
                "초 물고기자리",
                "힘찬 연어들처럼",
                "↑ {{TearsSmall}}연사(+상한) +0.5" ..
                "#공격이 파동 곡선을 그리면서 2발로 나가며 적을 밀쳐냅니다." ..
                "#" .. string.format("%.f", SPAWN_CHANCE * 100) .. "%의 확률로 적을 즉사시키는 눈물이 나가며;" ..
                "#{{ArrowGrayRight}} 보스에겐 공격력 x2의 피해를 줍니다." ..
                "#{{LuckSmall}} 행운 15 이상일 때 20% 확률 (행운 1당 +1%p)" ..
                "#{{TimerSmall}} (쿨타임 0.5초)",
                -- 중첩 시
                "중첩 시 발사 확률이 중첩된 수만큼 합연산으로 증가 및 쿨타임 감소"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.PISCES_EX,
                "Pisces EX",
                "",
                "↑ {{Tears}} +0.5 Fire rate" ..
                "#Increases tear knockback" ..
                "#Isaac shoots 2 tears at once and his tears move in waves" ..
                "#" .. string.format("%.f", SPAWN_CHANCE * 100) .. "% chance to fire a tear that instantly kill enemies;" ..
                "#{{ArrowGrayRight}} Deal 2x Isaac's damage against bosses" ..
                "#{{LuckSmall}} 20% chance at 15 luck (+1%p per Luck)",
                -- Stacks
                "On stacking, the firing chance increases per stack",
                "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.PISCES_EX) then
            local temporacyEffect = player:GetEffects()

            if not temporacyEffect:HasCollectibleEffect(CollectibleType.COLLECTIBLE_20_20) then
                temporacyEffect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_20_20, false, 1)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.PISCES_EX) then
            if cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_WIGGLE | TearFlags.TEAR_KNOCKBACK
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, TEARS_INCREMENT)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)
        local tearData = tear:GetData()

        if player ~= nil and player:HasCollectible(Astro.Collectible.PISCES_EX) then
            local data = player:GetData()

            if (data["piscesExCooldown"] == nil or data["piscesExCooldown"] < Game():GetFrameCount()) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.PISCES_EX)
                local collectibleNum = player:GetCollectibleNum(Astro.Collectible.PISCES_EX)

                if rng:RandomFloat() < math.min(MAX_CHANCE + ((collectibleNum - 1) / 20), (SPAWN_CHANCE + player.Luck * LUCK_MULTIPLY) * collectibleNum) then
                    tearData._ASTRO_piscesEx = {}

                    local modifiedColor = Color(1,1,1,1,0,0,0)
                    modifiedColor:SetColorize(1, 1.25, 4, 1.25)
                    tear:ChangeVariant(TearVariant.BALLOON)
                    tear.Color = modifiedColor

                    data["piscesExCooldown"] = Game():GetFrameCount() + COOLDOWN_TIME / collectibleNum
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    ---@param effect EntityEffect
    function(_, effect)
        local sprite = effect:GetSprite()
        sprite:Play("Explosion", true)
    end,
    WATER_SPLASH_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local sprite = effect:GetSprite()
        if sprite:IsFinished("Explosion") then
            effect:Remove()
        end
    end,
    WATER_SPLASH_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_TEAR_COLLISION,
    ---@param tear EntityTear
    ---@param collider Entity
    ---@param low boolean
    function(_, tear, collider, low)
        if tear:GetData()._ASTRO_piscesEx ~= nil then
            if not collider:IsDead() and collider:IsVulnerableEnemy() and collider.Type ~= EntityType.ENTITY_FIREPLACE then
                if not collider:IsBoss() then
                    local whirlpoolspawn = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WHIRLPOOL, 0, collider.Position, Vector.Zero, tear)
                    local whirlpool = whirlpoolspawn:ToEffect()
                    local eData = whirlpool:GetData()
                    eData._ASTRO_piscesEx_EffectScaleDecrease = 0
                    whirlpool.SpriteScale = Vector(2/3, 2/3)
                    whirlpool:FollowParent(collider)

                    Astro:ScheduleForUpdate(
                        function()
                            local splashSpawn = Isaac.Spawn(EntityType.ENTITY_EFFECT, WATER_SPLASH_VARIANT, 0, collider.Position, Vector.Zero, nil)
                            local splash = splashSpawn:ToEffect()
                            splash:FollowParent(whirlpoolspawn)

                            local sfx = SFXManager()
                            sfx:Play(SoundEffect.SOUND_BOSS2_DIVE, 0.75)

                            collider:Die()
                            eData._ASTRO_piscesEx_EffectScaleDecrease = 1
                        end,
                        10
                    )
                else
                    collider:TakeDamage(tear.BaseDamage, 0, EntityRef(tear), 0)
                end

                tear:GetData()._ASTRO_piscesEx = nil
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local eData = effect:GetData()

        if eData._ASTRO_piscesEx_EffectScaleDecrease == nil then
            return
        end

        if eData._ASTRO_piscesEx_EffectScaleDecrease < 1 then
            effect.SpriteScale = Vector(2/3, 2/3)
        elseif eData._ASTRO_piscesEx_EffectScaleDecrease >= 1 then
            if effect.SpriteScale.X > 0 and effect.SpriteScale.Y > 0 then
                effect.SpriteScale = effect.SpriteScale - Vector(0.03, 0.03)
            else
                effect:Remove()
            end
        end
    end,
    EffectVariant.WHIRLPOOL
)

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, PISCES_EX_VARIANT, 0, player.Position, Vector.Zero, nil):ToEffect()
        effect.Parent = player
        effect:FollowParent(player)
        effect:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    end,
    Astro.Collectible.PISCES_EX
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local parent = effect.Parent
        if parent ~= nil and parent:ToPlayer() and parent:ToPlayer():HasCollectible(Astro.Collectible.PISCES_EX) then
            effect.Velocity = parent.Velocity
        else
            effect:Remove()
        end
    end,
    PISCES_EX_VARIANT
)
Astro.Collectible.SNOWGRAVE = Isaac.GetItemIdByName("SnowGrave")

---

local SNOWFLAKE_VARIANT = 3117
local SNOWFALL_VARIANT = 3118
local SNOWSTAR_VARIANT = 3119

local SNOWFLAKE_AMOUNT = 100

local DESTROY_PILLAR = false    -- 기둥도 부수는지 여부

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.SNOWGRAVE,
                "눈무덤",
                "치명적",
                "#{{Freezing}} 사용 시 방 전체 적에게 9,999,999의 빙결 피해를 줍니다." ..
                "#{{Petrify}} 보스에게는 3초 동안 석화 효과 + 1,800의 피해를 줍니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.SNOWGRAVE,
                "SnowGrave", "",
                "#{{Freezing}} Deals 9,999,999 freeze damage to all enemies in the room" ..
                "#{{Petrify}} Deals 1,800 damage to the boss and petrifies for 3 seconds",
                nil, "en_us"
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data.snowgraveUsed = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        Astro.Data.snowgraveUsed = false
    end
)

local snowflakes = {}
local flakeSpawnTimer = 0
local snowfallOpacity = 0
local bellRepeatCycle = 7

local blueshadeEnable = false
local blueshadeSprite = Sprite()
blueshadeSprite:Load("gfx/snowgrave.anm2")
blueshadeSprite:Play("Background", true)

local readyEnable = -1
local readySprite = Sprite()
readySprite.PlaybackSpeed = 0.5
readySprite:Load("gfx/characters/costume_snowgrave.anm2")
readySprite:Play("Idle", true)

local function updateEnemiesFreeze()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if
            entity:ToProjectile()
            or entity:IsBoss()
            or entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE
            or not entity:IsVulnerableEnemy() and entity:ToNPC() 
        then
            entity:AddFreeze(EntityRef(Isaac.GetPlayer(readyEnable)), 600, true)
        end
    end
end

---@param position Vector
---@param customScale Vector?
local function spawnDust(position, customScale)
    for i = 1, 2 do
        customScale = customScale or 1

        local iceDustColor = Color(0.8, 0.8, 0.8, 1)
        iceDustColor:SetColorize(1, 1, 1, 0.5)
        iceDustColor:SetOffset(0.3, 0.5, 0.8)

        local dust = Isaac.Spawn(1000, EffectVariant.DUST_CLOUD, 0, position, Vector.Zero, nil):ToEffect()
        dust.Color = iceDustColor
        dust.SpriteScale = Vector(0.5, 0.5) * customScale
        dust:SetTimeout(30)
    end
end

local function killEnemies()
    local iceEnemyColor = Color(0.8, 0.8, 0.8, 1)
    iceEnemyColor:SetColorize(1, 1, 1, 0.5)
    iceEnemyColor:SetOffset(0.3, 0.5, 0.8)

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:ToProjectile() then
            entity:Die()
        elseif entity:ToBomb() then
            if entity.Variant == BombVariant.BOMB_TROLL or entity.Variant == BombVariant.BOMB_SUPERTROLL then
                entity:Remove()
                spawnDust(entity.Position - Vector(0, 10))
                Game():BombExplosionEffects(entity.Position, 0, nil, iceEnemyColor, Isaac.GetPlayer())
            end
        elseif entity.Type == EntityType.ENTITY_FIREPLACE or entity.Type == EntityType.ENTITY_SHOPKEEPER then
            entity:Die()
        else
            if not entity:IsBoss() and entity:IsActiveEnemy(false) and entity.Type ~= EntityType.ENTITY_FROZEN_ENEMY then
                entity:AddEntityFlags(EntityFlag.FLAG_ICE)
                entity:TakeDamage(9999999, 0, EntityRef(Isaac.GetPlayer(0)), 0)
            
                if Astro.Data.snowgraveUsed then
                    spawnDust(entity.Position - Vector(0, 10))
                    Isaac.Spawn(1000, SNOWSTAR_VARIANT, 0, entity.Position, Vector(math.random(-150, 150) / 100, math.random(-300, -100) / 100), nil)
                end
            elseif entity:IsBoss() then
                entity:AddFreeze(EntityRef(Isaac.GetPlayer(0)), 600, true)
                entity:TakeDamage(1800, 0, EntityRef(Isaac.GetPlayer(0)), 0)
                entity:SetColor(iceEnemyColor, 90, 1, true, false)

                if Astro.Data.snowgraveUsed then
                    spawnDust(entity.Position - Vector(0, 10), 1.5)
                    Isaac.Spawn(1000, SNOWSTAR_VARIANT, 0, entity.Position, Vector(math.random(-150, 150) / 100, math.random(-300, -100) / 100), nil)
                end
            end
        end
    end
end

---@param force boolean
local function destroyAllRocks(force)
    local game = Game()
    local room = game:GetRoom()
    local width = room:GetGridWidth()
    local height = room:GetGridHeight()

    local iceColor = Color(0.8, 0.8, 0.8, 1)
    iceColor:SetColorize(1, 1, 1, 0.5)
    iceColor:SetOffset(0.3, 0.5, 0.8)

    for i = 0, width * height - 1 do
        local gridEntity = room:GetGridEntity(i)
        local rock = gridEntity and gridEntity:ToRock()
        local poop = gridEntity and gridEntity:ToPoop()
        local door = gridEntity and gridEntity:ToDoor()

        if rock then
            if force then
                local type = rock:GetType()

                if type == GridEntityType.GRID_WALL or type == GridEntityType.GRID_PILLAR then
                    rock:SetType(GridEntityType.GRID_ROCK)
                end
            end

            success = rock:Destroy(false)
            
            if success then
                game:SpawnParticles(rock.Position, EffectVariant.ROCK_PARTICLE, 12, 5, iceColor, nil, 1) 
            end
        elseif poop then
            poop:Destroy(false)
        elseif door then
            local roomType = door.TargetRoomType

            if roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET then
                door:TryBlowOpen(true, Isaac.GetPlayer(0))
            end
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
        local room = Game():GetRoom()

        if not Astro.Data.snowgraveUsed and not room:IsMirrorWorld() then
            player:SetMinDamageCooldown(420)
            player.ControlsEnabled = false
            player.Visible = false

            readySprite:Play("Idle", true)
            readySprite.Scale = player.SpriteScale
            readyEnable = player.ControllerIndex

            MusicManager():Fadeout(0.02)
            updateEnemiesFreeze()
        else
            player:SetMinDamageCooldown(5)
            killEnemies()
            destroyAllRocks()
            Game():MakeShockwave(player.Position, 0.035, 0.025, 10)

            local sfx = SFXManager()
            
            if SoundEffect.SOUND_ITEM_RAISE and sfx:IsPlaying(SoundEffect.SOUND_ITEM_RAISE) then
                sfx:Stop(SoundEffect.SOUND_ITEM_RAISE)
            end

            sfx:Play(Astro.SoundEffect.SNOWGRAVE_USE, 0.75)
        end

        Astro.Data.snowgraveUsed = true
        
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = Astro.Data.snowgraveUsed or room:IsMirrorWorld(),
        }
    end,
    Astro.Collectible.SNOWGRAVE
)

------ 별 & 눈 입자 ------
Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    ---@param effect EntityEffect
    function(_, effect)
        local sprite = effect:GetSprite()

        sprite:Play("Stars", true)
    end,
    SNOWSTAR_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local sprite = effect:GetSprite()

        if sprite:IsFinished() then
            effect:Remove()
        end
    end,
    SNOWSTAR_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    ---@param effect EntityEffect
    function(_, effect)
        local sprite = effect:GetSprite()

        sprite:Play("Snowfall", true)
        sprite.Color = Color(1, 1, 1, 0)
        sprite.PlaybackSpeed = 2

        effect.Position = Vector.Zero
    end,
    SNOWFALL_VARIANT
)


------ 얼음 입자 ------
Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        effect.Velocity = Vector(0, -30)
        
        local sprite = effect:GetSprite()
        sprite.Scale = Vector(1.25, 1.25)
        
        local data = effect:GetData()
        data._ASTRO_SNOWFLAKE_SIN = math.sin(data._ASTRO_SNOWGRAVE / 6)

        if effect.FrameCount > SNOWFLAKE_AMOUNT then
            effect:Remove()
        end
    end,
    SNOWFLAKE_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function()
        if flakeSpawnTimer > 0 then
            local siner = ((SNOWFLAKE_AMOUNT + 1) - flakeSpawnTimer)

            local snowflake1 = Isaac.Spawn(1000, SNOWFLAKE_VARIANT, 0, Isaac.GetPlayer(readyEnable).Position + Vector(-35, 560), Vector.Zero, nil)
            local snowflake2 = Isaac.Spawn(1000, SNOWFLAKE_VARIANT, 0, Isaac.GetPlayer(readyEnable).Position + Vector(0, 600), Vector.Zero, nil)
            local snowflake3 = Isaac.Spawn(1000, SNOWFLAKE_VARIANT, 0, Isaac.GetPlayer(readyEnable).Position + Vector(35, 520), Vector.Zero, nil)

            local data1, data2, data3 = snowflake1:GetData(), snowflake2:GetData(), snowflake3:GetData()
            data1._ASTRO_SNOWGRAVE = siner
            data1._ASTRO_SNOWFLAKE_SIN = math.sin(data1._ASTRO_SNOWGRAVE / 6)
            data2._ASTRO_SNOWGRAVE = siner
            data2._ASTRO_SNOWFLAKE_SIN = math.sin(data2._ASTRO_SNOWGRAVE / 6)
            data3._ASTRO_SNOWGRAVE = siner
            data3._ASTRO_SNOWFLAKE_SIN = math.sin(data3._ASTRO_SNOWGRAVE / 6)

            table.insert(snowflakes, snowflake1)
            table.insert(snowflakes, snowflake2)
            table.insert(snowflakes, snowflake3)

            flakeSpawnTimer = flakeSpawnTimer - 1
        end
    end
)


------ 렌더링 ------
Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function()
        local game = Game()
        local screenWidth = Isaac.GetScreenWidth()
        local screenHeight = Isaac.GetScreenHeight()
        local sfx = SFXManager()
        
        ----

        if readyEnable > -1 then
            if not game:IsPaused() then
                readySprite:Update()
            end

            readySprite:Render(Astro:ToScreen(Isaac.GetPlayer(readyEnable).Position), Vector.Zero, Vector.Zero)

            if readySprite:IsEventTriggered("spawnstars") then
                sfx:Play(Astro.SoundEffect.SNOWGRAVE_BELL)
            end

            if readySprite:WasEventTriggered("spawnstars") and not readySprite:IsFinished() then
                if bellRepeatCycle == 0 then
                    if not game:IsPaused() then
                        Isaac.Spawn(1000, SNOWSTAR_VARIANT, 0, Isaac.GetPlayer(readyEnable).Position + Vector(0, -50), Vector(math.random(-150, 150) / 100, math.random(-300, -100) / 100), nil)
                    end

                    updateEnemiesFreeze()
                    bellRepeatCycle = 7
                else
                    bellRepeatCycle = bellRepeatCycle - 1
                end
            end

            if readySprite:IsEventTriggered("blueshade") then
                sfx:Play(Astro.SoundEffect.SNOWGRAVE)

                blueshadeSprite:Play("Background", true)
                blueshadeEnable = true

                Isaac.Spawn(1000, SNOWFALL_VARIANT, 0, Vector.Zero, Vector.Zero, nil)
            end
        end

        ----

        local flakes = snowflakes
        local room = game:GetRoom()
        local offset = room:GetRenderScrollOffset()
        
        if #flakes > 0 then
            for i = #snowflakes, 1, -1 do
                local effect = snowflakes[i]

                if not effect:Exists() then
                    table.remove(snowflakes, i)
                else
                    local data = effect:GetData()

                    effect:Render(Vector(data._ASTRO_SNOWFLAKE_SIN * 30, 0) + offset)
                    effect:Render(Vector(data._ASTRO_SNOWFLAKE_SIN * -30, 0) + offset)
                end
            end
        end
        
        ----

        if blueshadeEnable then
            blueshadeSprite.Scale = Vector(0.002 * screenWidth, 0.002 * screenHeight)

            if not game:IsPaused() then
                blueshadeSprite:Update()
            end
            
            blueshadeSprite:Render(Vector.Zero, Vector.Zero, Vector.Zero)

            if blueshadeSprite:IsEventTriggered("spawnflakes") then
                flakeSpawnTimer = SNOWFLAKE_AMOUNT
                updateEnemiesFreeze()
            end

            if blueshadeSprite:IsEventTriggered("killEnemies") then
                updateEnemiesFreeze()
                killEnemies()
                destroyAllRocks()
            end

            if blueshadeSprite:IsFinished() then
                Isaac.GetPlayer(readyEnable).ControlsEnabled = true
                Isaac.GetPlayer(readyEnable).Visible = true
                Isaac.GetPlayer(readyEnable):PlayExtraAnimation("HideItem") 

                blueshadeEnable = false
                readyEnable = -1
                snowfallOpacity = 0

                local music = MusicManager()
                music:Fadein(music:GetQueuedMusicID(), Options.MusicVolume, 0.02)
            end

            local falls = Isaac.FindByType(1000, SNOWFALL_VARIANT)
            
            if #falls > 0 then
                for _, effect in pairs(falls) do
                    if blueshadeSprite:IsFinished() then
                        effect:Remove()
                        goto continue
                    end

                    for i = -128, screenWidth + 128, 128 do
                        for j = -128, screenHeight + 128, 128 do
                            effect:Render(Vector(i, j))
                        end
                    end
                    
                    local finOpacity

                    if blueshadeSprite:GetFrame() < 360 then
                        snowfallOpacity = math.min(15, snowfallOpacity + 1)
                        finOpacity = snowfallOpacity / 15
                    else
                        snowfallOpacity = math.min(45, snowfallOpacity + 1)
                        finOpacity = (45 - snowfallOpacity) / 15
                    end

                    if blueshadeSprite:IsEventTriggered("speedup") then
                        updateEnemiesFreeze()
                        effect:GetSprite().PlaybackSpeed = 1 + (blueshadeSprite:GetFrame() - 50) / 4
                    end

                    effect:GetSprite().Color = Color(1, 1, 1, finOpacity)

                    ::continue::
                end
            end
        end
    end
)

Astro.Collectible.OVERMIND = Isaac.GetItemIdByName("Overmind")

---

local SPEED_INCREMENT = 0.005
local TEARS_INCREMENT = 0.05
local DAMAGE_INCREMENT = 0.05
local RANGE_INCREMENT = 0.1
local SHOTSPEED_INCREMENT = 0.005
local LUCK_INCREMENT = 0.1

local CONTROL_SENSITIVITY = 5

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.OVERMIND,
                "초월체",
                "너는 나를 섬기기 위해 창조되었다",
                "방 입장 시 방 안의 파란 아군 거미/파리의 개수만큼 능력치 증가:" ..
                "#{{ArrowGrayRight}} {{DamageSmall}} 공격력 +" .. DAMAGE_INCREMENT ..
                "#{{ArrowGrayRight}} {{TearsSmall}} 연사(+상한) +" .. TEARS_INCREMENT ..
                "#{{ArrowGrayRight}} {{RangeSmall}} 사거리 +" .. RANGE_INCREMENT ..
                "#{{ArrowGrayRight}} {{SpeedSmall}} 이동속도 +" .. SPEED_INCREMENT ..
                "#{{ArrowGrayRight}} {{ShotspeedSmall}} 탄속 +" .. SHOTSPEED_INCREMENT ..
                "#{{ArrowGrayRight}} {{LuckSmall}} 행운 +" .. LUCK_INCREMENT ..
                "#{{Collectible248}} 파란 아군 거미/파리와 파리/거미 타입의 패밀리어의 공격력이 2배 증가합니다." ..
                "#파란 아군 거미/파리의 이동 방향을 조종할 수 있습니다.",
                -- 중첩 시
                "중첩 시 능력치 상승량이 합연산으로 증가"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.OVERMIND,
                "Overmind", "",
                "#{{Collectible248}} Blue spiders and flies deal double damage, and Spider and fly familiars become stronger" ..
                "#Blue spiders and flies movement direction can be controlled with the attack buttons" ..
                "#↑ Increases stats by the number of blue flies and spiders in the room when entering a room:" ..
                "#{{ArrowGrayRight}} {{Speed}} +" .. SPEED_INCREMENT .. " Speed" ..
                "#{{ArrowGrayRight}} {{Tears}} +" .. TEARS_INCREMENT .. " Tears" ..
                "#{{ArrowGrayRight}} {{Damage}} +" .. DAMAGE_INCREMENT .. " Damage" ..
                "#{{ArrowGrayRight}} {{Range}} +" .. RANGE_INCREMENT .. " Range" ..
                "#{{ArrowGrayRight}} {{Shotspeed}} +" .. SHOTSPEED_INCREMENT .. " Shot speed" ..
                "#{{ArrowGrayRight}} {{Luck}} +" .. LUCK_INCREMENT .. " Luck",
                -- Stacks
                "Stacks increase the stat boost amount",
                "en_us"
            )
        end
    end
)

------ 하이브 ------
Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:HasCollectible(Astro.Collectible.OVERMIND) then
            local temporacyEffect = player:GetEffects()

            if not temporacyEffect:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HIVE_MIND) then
                temporacyEffect:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HIVE_MIND, false, 1)
            end
        end
    end
)

------ 파리/거미 ------
Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        local player = familiar.Player
        local adjustSpeed, adjustSpeed2 = 1, 1

        if
            player
            and player:HasCollectible(Astro.Collectible.OVERMIND)
            and (familiar.Variant == FamiliarVariant.BLUE_FLY or familiar.Variant == FamiliarVariant.BLUE_SPIDER)
        then
            if familiar.Variant == FamiliarVariant.BLUE_FLY then
                familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            end

            if familiar.Variant == FamiliarVariant.BLUE_SPIDER then
                adjustSpeed, adjustSpeed2 = 1.8, 2
            end

            local nearEnemies = Isaac.FindInRadius(familiar.Position, 40, EntityPartition.ENEMY)
            if #nearEnemies < 1 then
                local mousePos = Input.GetMousePosition(true)
                local distanceBtwMouseFam = mousePos - familiar.Position
                local nomralized = distanceBtwMouseFam:Normalized()
                
                if Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_1) then
                    familiar.Velocity = (familiar.Velocity / adjustSpeed) + (nomralized * CONTROL_SENSITIVITY * (adjustSpeed * adjustSpeed2))
                else
                    familiar.Velocity = (familiar.Velocity / adjustSpeed) + (player:GetShootingJoystick() * CONTROL_SENSITIVITY * (adjustSpeed * adjustSpeed2))
                end
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.SPAWNED_BLUE_FLY,
    ---@param fly EntityFamiliar
    function(_, fly)
        local player = fly.Player

        if not player:HasCollectible(Astro.Collectible.OVERMIND) then
            return
        end

        fly.Color = Color(0.5, 0, 0.3, 1, 0.12, 0, 0)
    end
)

Astro:AddCallback(
    Astro.Callbacks.SPAWNED_BLUE_SPIDER,
    ---@param spider EntityFamiliar
    function(_, spider)
        local player = spider.Player

        if not player:HasCollectible(Astro.Collectible.OVERMIND) then
            return
        end

        spider.Color = Color(0.1, 0, 0, 1, 0.15, 0, 0.05)
    end
)


------ 스탯 ------
local statIncrease = 0

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.OVERMIND) then
                local flies = #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY)
                local spiders = #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER)

                if statIncrease < (flies + spiders) then
                    statIncrease = flies + spiders
                else
                    statIncrease = statIncrease
                end

                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK)
                player:EvaluateItems()
            else
                statIncrease = 0
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.OVERMIND) then
            local collectibleNum = player:GetCollectibleNum(Astro.Collectible.OVERMIND)

            if cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + (SPEED_INCREMENT * statIncrease * collectibleNum)
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, (TEARS_INCREMENT * statIncrease * collectibleNum))
            elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + (DAMAGE_INCREMENT * statIncrease * collectibleNum)
            elseif cacheFlag == CacheFlag.CACHE_RANGE then
                player.TearRange =player.TearRange + (SPEED_INCREMENT * 40 * statIncrease * collectibleNum)
            elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
                player.ShotSpeed = player.ShotSpeed + (SHOTSPEED_INCREMENT * statIncrease * collectibleNum)
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + (LUCK_INCREMENT * statIncrease * collectibleNum)
            end
        end
    end
)


local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SUPER_ROCKET_IN_A_JAR = Isaac.GetItemIdByName("Super Rocket in a Jar")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.SUPER_ROCKET_IN_A_JAR,
                "슈퍼 로켓 든 병",
                "폭탄 5개 + 엄청난 로켓 발사!",
                "↑ {{Bomb}}폭탄 +5" ..
                "#{{Collectible583}} 폭탄 대신 기가 로켓이 나가며 기가 로켓은 공격방향으로 날아가 폭발합니다."
            )
        end
    end
)

------ 아래부터 사왈이 수정

local GIGA_ROCKETS = {}

Astro:AddCallback(
    ModCallbacks.MC_POST_BOMB_INIT,
    ---@param bomb EntityBomb
    function(_, bomb)
        local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
        if player and player:HasCollectible(Astro.Collectible.SUPER_ROCKET_IN_A_JAR) then
            local gigarocket = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_ROCKET_GIGA, 0, bomb.Position, bomb.Velocity, bomb.SpawnerEntity)
            bomb:Remove()

            local dir = player:GetFireDirection()
            local knockback = Vector(0, 0)
            if dir == Direction.UP then
                knockback = Vector(0, 6)
            elseif dir == Direction.LEFT then
                knockback = Vector(6, 0)
            elseif dir == Direction.DOWN then
                knockback = Vector(0, -6)
            elseif dir == Direction.RIGHT then
                knockback = Vector(-6, 0)
            end
            player:AddVelocity(knockback)
            
            local data = gigarocket:GetData()
            data.ASTRO_SUPERROCKET_Modded = true
            data.ASTRO_SUPERROCKET_SpriteInit = false
            data.ASTRO_SUPERROCKET_Direction = dir

            GIGA_ROCKETS[gigarocket.InitSeed] = gigarocket
        end
    end,
    19
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,    -- 첫 프레임 동안은 로켓이 오른쪽을 바라봐서 플레이어 업데이트로 고정
    ---@param player EntityPLAYER
    function(_, player)
        for seed, gigarocket in pairs(GIGA_ROCKETS) do
            if not gigarocket or not gigarocket:Exists() then
                GIGA_ROCKETS[seed] = nil
            else
                local data = gigarocket:GetData()
                if data.ASTRO_SUPERROCKET_SpriteInit then goto continue end

                if data.ASTRO_SUPERROCKET_Modded then
                    local dir = data.ASTRO_SUPERROCKET_Direction
                    local spr = gigarocket:GetSprite()

                    if dir == Direction.UP then
                        spr.Rotation = -90
                    elseif dir == Direction.LEFT then
                        spr.Scale = Vector(-1, 1)
                    elseif dir == Direction.DOWN then
                        spr.Rotation = 90
                    end

                    data.ASTRO_SUPERROCKET_SpriteInit = true
                end
            end
            ::continue::
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_BOMB_UPDATE,
    ---@param player EntityBomb
    function(_, bomb)
        for seed, gigarocket in pairs(GIGA_ROCKETS) do
            if not gigarocket or not gigarocket:Exists() then
                GIGA_ROCKETS[seed] = nil
            else
                local data = gigarocket:GetData()
                if data.ASTRO_SUPERROCKET_Modded then
                    local spr = gigarocket:GetSprite()
                    local dir = data.ASTRO_SUPERROCKET_Direction

                    if dir == Direction.UP then
                        gigarocket:AddVelocity(Vector(0, -1.6))
                        gigarocket.Velocity = Vector(-0.6, gigarocket.Velocity.Y)
                        spr.Rotation = -90
                    elseif dir == Direction.LEFT then
                        gigarocket:AddVelocity(Vector(-1.6, 0))
                        spr.Scale = Vector(-1, 1)
                    elseif dir == Direction.DOWN then
                        gigarocket:AddVelocity(Vector(0, 1.6))
                        gigarocket.Velocity = Vector(-0.6, gigarocket.Velocity.Y)
                        spr.Rotation = 90
                    end
                end
            end
        end
    end
)

------


Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR, player:HasCollectible(Astro.Collectible.SUPER_ROCKET_IN_A_JAR) and 1 or 0, "ASTRO_ASTRO_SUPER_ROCKET_IN_A_JAR")
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    function(_, player)
        if Astro:IsFirstAdded(Astro.Collectible.SUPER_ROCKET_IN_A_JAR) then
            player:AddBombs(5)
        end
    end,
    Astro.Collectible.SUPER_ROCKET_IN_A_JAR
)
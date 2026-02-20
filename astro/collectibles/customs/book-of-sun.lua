---

local SUN_FLAME_SPAWN_CHANCE = 0.1
local ECLIPSE_FLAME_SPAWN_CHANCE = 0.1

local SUN_LUCK_MULTIPLY = 1 / 100
local ECLIPSE_LUCK_MULTIPLY = 1 / 100

---

Astro.Collectible.BOOK_OF_SUN = Isaac.GetItemIdByName("Book of Sun")
Astro.Collectible.BOOK_OF_ECLIPSE = Isaac.GetItemIdByName("Book of Eclipse")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.BOOK_OF_SUN,
                "태양의 서",
                "충전식 화염 공격",
                "!!! 다음 게임에서 Burning Basement 스테이지 미등장" ..
                "#{{Burning}} 사용 시 그 방의 적에게 화상을 입히며;" ..
                "#{{ArrowGrayRight}} 게임당 한번 {{Card20}}XIX - The Sun을 소환합니다." ..
                "#소지중일 때 10%의 확률로 적이 죽은 자리에 빨간 불을 소환합니다." ..
                "#{{LuckSmall}} 행운 90 이상일 때 100% 확률 (행운 1당 +1%p)"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.BOOK_OF_ECLIPSE,
                "개기일식의 서",
                "불타오르네",
                "!!! 다음 게임에서 Burning Basement 스테이지 미등장" ..
                "#{{Burning}} 사용 시 그 방의 적에게 화상을 입히며;" ..
                "#{{ArrowGrayRight}} 게임당 한번 {{Card75}}XIX - The Sun?을 소환합니다." ..
                "#소지중일 때 10%의 확률로 적이 죽은 자리에 파란 불을 소환합니다." ..
                "#{{LuckSmall}} 행운 90 이상일 때 100% 확률 (행운 1당 +1%p)"
            )

            ----

            Astro.EID:AddCollectible(
                Astro.Collectible.BOOK_OF_SUN,
                "Book of Sun", "",
                "!!! No Burning Basement in next run" ..
                "#Upon use:" ..
                "#{{Burning}} Burns room enemies" ..
                "#{{Card20}} Spawns the Sun once per run" ..
                "#10% chance to spawn red fire at enemy death while held (+1%p per Luck)",
                nil, "en_us"
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.BOOK_OF_ECLIPSE,
                "Book of Eclipse", "",
                "!!! No Burning Basement in next run" ..
                "#Upon use:" ..
                "#{{Burning}} Burns room enemies" ..
                "#{{Card75}} Spawns the Sun? once per run" ..
                "#10% chance to spawn blue fire at enemy death while held (+1%p per Luck)",
                nil, "en_us"
            )

            ----

            Astro.EID.LuckFormulas["5.100." .. tostring(Astro.Collectible.BOOK_OF_SUN)] = function(luck, num)
                return (SUN_FLAME_SPAWN_CHANCE + luck * SUN_LUCK_MULTIPLY) * 100
            end
            
            Astro.EID.LuckFormulas["5.100." .. tostring(Astro.Collectible.BOOK_OF_ECLIPSE)] = function(luck, num)
                return (ECLIPSE_FLAME_SPAWN_CHANCE+ luck * ECLIPSE_LUCK_MULTIPLY) * 100
            end
        end
    end
)

-- TODO: 스테이지 밴 기능을 Deneb랑 통합 관리해야합니다.

local function TryChangeStage()
    if Astro.Data["banBurningBasementStage"] then
        local level = Game():GetLevel()
        local stage = level:GetStage()
        local rng = Isaac.GetPlayer():GetCollectibleRNG(Astro.Collectible.BOOK_OF_SUN)

        if level:GetStageType() == StageType.STAGETYPE_AFTERBIRTH and stage <= LevelStage.STAGE1_2 then
            Isaac.ExecuteCommand("stage " .. stage .. (rng:RandomFloat() < 0.5 and "" or "a"))
            print("Book of Sun Effect: Ban Burning Basement Stage")
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            if Astro.Data["usedBookOfSun"] or Astro.Data["usedBookOfEclipse"] then
                Astro.Data["banBurningBasementStage"] = true
                TryChangeStage()
            else
                Astro.Data["banBurningBasementStage"] = false
            end

            Astro.Data["usedBookOfSun"] = false
            Astro.Data["usedBookOfEclipse"] = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Game():GetFrameCount() > 1 then
            TryChangeStage()
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleType CollectibleType
    ---@param rng RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleType, rng, player, useFlags, activeSlot, varData)
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
                entity:AddBurn(EntityRef(player), 103, player.Damage)
            end
        end

        if not Astro.Data["usedBookOfSun"] then
            Astro.Data["usedBookOfSun"] = true
            Astro:SpawnCard(Card.CARD_SUN, player.Position)
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.BOOK_OF_SUN
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleType CollectibleType
    ---@param rng RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleType, rng, player, useFlags, activeSlot, varData)
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
                entity:AddBurn(EntityRef(player), 103, player.Damage)
            end
        end

        if not Astro.Data["usedBookOfEclipse"] then
            Astro.Data["usedBookOfEclipse"] = true
            Astro:SpawnCard(Card.CARD_REVERSE_SUN, player.Position)
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.BOOK_OF_ECLIPSE
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.BOOK_OF_SUN) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.BOOK_OF_SUN)
    
                if rng:RandomFloat() < (SUN_FLAME_SPAWN_CHANCE + player.Luck * SUN_LUCK_MULTIPLY) then
                    local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, entityNPC.Position, Vector.Zero, Isaac.GetPlayer())
                    flame.CollisionDamage = 23
                    break
                end
            end
        end

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.BOOK_OF_ECLIPSE) then
                local rng = player:GetCollectibleRNG(Astro.Collectible.BOOK_OF_ECLIPSE)
    
                if rng:RandomFloat() < (ECLIPSE_FLAME_SPAWN_CHANCE + player.Luck * ECLIPSE_LUCK_MULTIPLY) then
                    local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, entityNPC.Position, Vector.Zero, Isaac.GetPlayer())
                    flame.CollisionDamage = 23

                    local sprite = flame:GetSprite()
                    sprite:ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_blue.png")
                    sprite:LoadGraphics()

                    break
                end
            end
        end
    end
)

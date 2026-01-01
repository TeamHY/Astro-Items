local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.CHUBBYS_HEAD = Isaac.GetItemIdByName("Chubby's Head")
Astro.Collectible.SLEEPING_PUPPY = Isaac.GetItemIdByName("Sleeping Puppy")
Astro.Collectible.CHUBBYS_TAIL = Isaac.GetItemIdByName("Chubby's Tail")

local chubbyUpSound = Isaac.GetSoundIdByName('ChubbyUp')

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local chubbyIcon = Sprite()
            chubbyIcon:Load("gfx/ui/eid/astro_transform.anm2", true)
            EID:addIcon("TransformChubby", "Transformation1", 0, 16, 16, 0, -1, chubbyIcon)
            EID:createTransformation("TransformChubby", "Chubby!!!")

            EID:assignTransformation("collectible", Astro.Collectible.CHUBBYS_HEAD, "TransformChubby")
            EID:assignTransformation("collectible", Astro.Collectible.SLEEPING_PUPPY, "TransformChubby")
            EID:assignTransformation("collectible", Astro.Collectible.CHUBBYS_TAIL, "TransformChubby")
            EID:assignTransformation("collectible", CollectibleType.COLLECTIBLE_DOG_TOOTH, "TransformChubby")
            EID:assignTransformation("collectible", CollectibleType.COLLECTIBLE_LITTLE_CHUBBY, "TransformChubby")
            EID:assignTransformation("collectible", CollectibleType.COLLECTIBLE_BIG_CHUBBY, "TransformChubby")

            Astro.EID:AddCollectible(
                Astro.Collectible.CHUBBYS_HEAD,
                "처비의 머리",
                "'^'",
                "↑ {{DamageSmall}} 최종 공격력 +3.5",
                -- 중첩 시
                "중첩 가능"
            )
            Astro.EID:AddCollectible(
                Astro.Collectible.SLEEPING_PUPPY,
                "잠자는 강아지",
                "드르렁...",
                "↑ {{DamageSmall}} 공격력 +0.35" ..
                "#9개의 방을 클리어할 때마다 {{DamageSmall}}공격력, {{TearsSmall}}연사, {{RangeSmall}}사거리, {{SpeedSmall}}이동속도, {{LuckSmall}}행운 중 하나 +0.35",
                -- 중첩 시
                "중첩 가능, 다음 증가량부터 적용"
            )
            Astro.EID:AddCollectible(
                Astro.Collectible.CHUBBYS_TAIL,
                "처비의 꼬리",
                "살랑살랑",
                "{{Chest}} 일반상자 등장 시 33%의 확률로 한개 더 등장합니다.",
                -- 중첩 시
                "중첩 시 추가 등장 확률이 합 연산으로 증가"
            )
        end
    end
)

-- 처비셋 목록
local CHUBBY_SET_LIST = {
    Astro.Collectible.CHUBBYS_HEAD,
    Astro.Collectible.SLEEPING_PUPPY,
    Astro.Collectible.CHUBBYS_TAIL,
    -- Astro.Collectible.LIBRA_EX, -- 순서 문제로 별도 처리
    CollectibleType.COLLECTIBLE_DOG_TOOTH,
    CollectibleType.COLLECTIBLE_LITTLE_CHUBBY,
    CollectibleType.COLLECTIBLE_BIG_CHUBBY,
}

-- 처비셋 쿨타임
local CHUBBY_SET_COOLDOWN_TIME = 15 -- 30 프레임 당 하나

-- 처비셋 눈물 발사 시 효과 발동 확률
local CHUBBY_SET_CHANCE = 0.5
local CHUBBY_SET_BIG_CHUBBY_CHANCE = 0.5

-- 처비의 머리
local CHUBBYS_HEAD_DAMAGE = 3.5

-- 잠자는 강아지
local SLEEPING_PUPPY_INCREMENT = 0.35
local SLEEPING_PUPPY_VOULME = 2
local SLEEPING_PUPPY_DAMAGE = 0.35

-- 처비의 꼬리
local CHUBBYS_TAIL_SUBTYPE = 1000
local CHUBBYS_TAIL_CHANCE = 0.33

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data.SleepingPuppy = {
                RoomClearCount = 0,
                Damage = 0,
                FireDelay = 0,
                Range = 0,
                Speed = 0,
                Luck = 0
            }

            Astro.Data.ChubbySet = 0
        else
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(Astro.Collectible.SLEEPING_PUPPY) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:AddCacheFlags(CacheFlag.CACHE_RANGE)
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    ---@param tear EntityTear
    function(_, tear)
        local player = Astro:GetPlayerFromEntity(tear)

        if player ~= nil then
            local data = player:GetData()

            if (not data["chubbySetCooldown"] or data["chubbySetCooldown"] < Game():GetFrameCount()) and Astro.Data.ChubbySet >= 3 then
                local rng = player:GetCollectibleRNG(Astro.Collectible.CHUBBYS_HEAD)

                if rng:RandomFloat() < CHUBBY_SET_CHANCE then
                    ---@type EntityFamiliar
                    local fmailiar

                    if rng:RandomFloat() < CHUBBY_SET_BIG_CHUBBY_CHANCE then
                        fmailiar = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BIG_CHUBBY, 10, tear.Position, Vector.Zero, nil):ToFamiliar()
                    else
                        fmailiar = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.LITTLE_CHUBBY, 10, tear.Position, Vector.Zero, nil):ToFamiliar()
                    end

                    fmailiar:GetData().IsChubbySets = true

                    data["chubbySetCooldown"] = Game():GetFrameCount() + CHUBBY_SET_COOLDOWN_TIME
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        local data = familiar:GetData()

        if data.IsChubbySets == true and (familiar.Variant == FamiliarVariant.LITTLE_CHUBBY or familiar.Variant == FamiliarVariant.BIG_CHUBBY) then
            local isShooting = string.find(familiar:GetSprite():GetAnimation(), "Shoot") ~= nil

            if isShooting then
                data.IsDisposable = true
            elseif not isShooting and data.IsDisposable == true then
                familiar:Remove()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function()
        local isRun = false

        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if Astro.Data.SleepingPuppy ~= nil and player:HasCollectible(Astro.Collectible.SLEEPING_PUPPY) then
                if not isRun then
                    Astro.Data.SleepingPuppy.RoomClearCount = Astro.Data.SleepingPuppy.RoomClearCount + 1

                    if Astro.Data.SleepingPuppy.RoomClearCount % 9 == 0 then
                        local rng = player:GetCollectibleRNG(Astro.Collectible.SLEEPING_PUPPY)
                        local random = rng:RandomInt(5)
                        local statusIncrement = SLEEPING_PUPPY_INCREMENT * player:GetCollectibleNum(Astro.Collectible.SLEEPING_PUPPY)

                        if random == 0 then
                            Astro.Data.SleepingPuppy.Damage = Astro.Data.SleepingPuppy.Damage + statusIncrement
                        elseif random == 1 then
                            Astro.Data.SleepingPuppy.FireDelay = Astro.Data.SleepingPuppy.FireDelay + statusIncrement
                        elseif random == 2 then
                            Astro.Data.SleepingPuppy.Range = Astro.Data.SleepingPuppy.Range + statusIncrement
                        elseif random == 3 then
                            Astro.Data.SleepingPuppy.Speed = Astro.Data.SleepingPuppy.Speed + statusIncrement
                        elseif random == 4 then
                            Astro.Data.SleepingPuppy.Luck = Astro.Data.SleepingPuppy.Luck + statusIncrement
                        end

                        SFXManager():Play(chubbyUpSound, SLEEPING_PUPPY_VOULME)
                    end

                    isRun = true
                end

                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:AddCacheFlags(CacheFlag.CACHE_RANGE)
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                player:EvaluateItems()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.CHUBBYS_HEAD) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + CHUBBYS_HEAD_DAMAGE * player:GetCollectibleNum(Astro.Collectible.CHUBBYS_HEAD)
            end
        end
        
        if player:HasCollectible(Astro.Collectible.SLEEPING_PUPPY) and Astro.Data.SleepingPuppy ~= nil then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + SLEEPING_PUPPY_DAMAGE + Astro.Data.SleepingPuppy.Damage
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, Astro.Data.SleepingPuppy.FireDelay)
            elseif cacheFlag == CacheFlag.CACHE_RANGE then
                player.TearRange = player.TearRange + Astro.Data.SleepingPuppy.Range
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + Astro.Data.SleepingPuppy.Speed
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + Astro.Data.SleepingPuppy.Luck
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_INIT,
    ---@param pickup EntityPickup
    function(_, pickup)
        if pickup.Variant == PickupVariant.PICKUP_CHEST and pickup.SubType ~= CHUBBYS_TAIL_SUBTYPE then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.CHUBBYS_TAIL) then
                    local rng = player:GetCollectibleRNG(Astro.Collectible.CHUBBYS_TAIL)

                    if rng:RandomFloat() < CHUBBYS_TAIL_CHANCE * player:GetCollectibleNum(Astro.Collectible.CHUBBYS_TAIL) then
                        local currentRoom = Game():GetLevel():GetCurrentRoom()

                        Isaac.Spawn(
                            EntityType.ENTITY_PICKUP,
                            PickupVariant.PICKUP_CHEST,
                            CHUBBYS_TAIL_SUBTYPE,
                            currentRoom:FindFreePickupSpawnPosition(pickup.Position, 40, true),
                            Vector.Zero,
                            nil
                        )
                    end

                    break
                end
            end

            pickup.SubType = CHUBBYS_TAIL_SUBTYPE
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:Contain(CHUBBY_SET_LIST, collectibleType) and Astro:IsFirstAdded(collectibleType) then
            Astro.Data.ChubbySet = Astro.Data.ChubbySet + 1

            if Astro.Data.ChubbySet == 3 then
                local Flavor
                if Options.Language == "kr" or REPKOR then
                    Flavor = "처비!!!"
                else
                    Flavor = "Chubby!!!"
                end

                SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
                Game():GetHUD():ShowItemText(Flavor)
            end
        end
    end
)

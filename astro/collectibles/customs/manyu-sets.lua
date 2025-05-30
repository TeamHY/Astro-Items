---
local REINCARNATION_ITEMS = {
    CollectibleType.COLLECTIBLE_1UP,
    CollectibleType.COLLECTIBLE_LAZARUS_RAGS,
    CollectibleType.COLLECTIBLE_ANKH,
    Astro.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL
}

local REINCARNATION_DAMAGE_MULTIPLIER = 0.5

-- 마트료시카 공격력 증가량
local MATRYOSHKA_DAMAGE = 0.05

-- 마트료시카 연사 증가량
local MATRYOSHKA_FIRE_DELAY = 0.05

-- 마트료시카 이동 속도 증가량
local MATRYOSHKA_SPEED = 0.05

-- 마트료시카 행운 증가량
local MATRYOSHKA_LUCK = 0.05

-- 미니 상자가 등장할 확률 (0 ~ 1)
local MATRYOSHKA_CHANCE = 0.4

-- 처비의 꼬리 소지 시 미니 상자가 등장할 확률 (0 ~ 1)
local MATRYOSHKA_WITH_CHUBBYS_TAIL_CHANCE = 0.2

-- 효과음 볼륨
local MATRYOSHKA_SOUND_VOLUME = 1.0
---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.REINCARNATION = Isaac.GetItemIdByName("Reincarnation")
Astro.Collectible.MATRYOSHKA = Isaac.GetItemIdByName("Matryoshka")
Astro.Collectible.SAMSARA = Isaac.GetItemIdByName("Samsara")

-- 만유의 생멸셋 목록
local MANYU_SET_LIST = {
    Astro.Collectible.REINCARNATION,
    Astro.Collectible.MATRYOSHKA,
    Astro.Collectible.SAMSARA
}

local chubbyUpSound = Isaac.GetSoundIdByName('ChubbyUp')

if EID then
    -- NOTE: 불교 용어인듯하여 음역했습니다
    EID:createTransformation("Saengmyeol of Manyu", "만유의 생멸")

    EID:assignTransformation("collectible", Astro.Collectible.REINCARNATION, "Saengmyeol of Manyu")
    EID:assignTransformation("collectible", Astro.Collectible.MATRYOSHKA, "Saengmyeol of Manyu")
    EID:assignTransformation("collectible", Astro.Collectible.SAMSARA, "Saengmyeol of Manyu")

    Astro:AddEIDCollectible(
        Astro.Collectible.REINCARNATION,
        "리인카네이션",
        "...",
        "다음 게임에서 부활류 아이템 중 하나를 소환합니다." ..
        "#소지중인 부활류 아이템 하나당 {{DamageSmall}}공격력 +50%p"
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.MATRYOSHKA,
        "마트료시카",
        "...",
        "상자를 열 때마다 {{DamageSmall}}공격력, {{TearsSmall}}연사, {{SpeedSmall}}이동속도, {{LuckSmall}}행운 중 하나 +0.5(고정)" ..
        "#중첩 시 다음 증가량부터 적용됩니다." ..
        "#{{WoodenChest}}나무상자를 열 때 50% 확률로 작은 상자가 소환됩니다. {{Collectible" .. Astro.Collectible.CHUBBYS_TAIL .. "}}Chubby's Tail 소지 시 20% 확률로 소환됩니다." ..
        "#{{ColorRed}}BUG: 상자에서 패시브, 액티브 아이템이 등장할 경우 능력치가 증가하지 않습니다."
    )

    Astro:AddEIDCollectible(
        Astro.Collectible.SAMSARA,
        "삼사라",
        "...",
        "적 처치 시 {{Collectible522}}Telekinesis가 발동합니다. (방마다 최대 1번)" ..
        "#중첩 시 여러 번 발동할 수 있습니다." ..
        "#Astrobirth의 NextBan 시스템이 무효화됩니다."
    )
end

--#region Reincarnation

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and Astro.Data.RunReincarnation then
            local player = Isaac.GetPlayer()
            local rng = player:GetCollectibleRNG(Astro.Collectible.REINCARNATION)

            local item = Astro:GetRandomCollectibles(REINCARNATION_ITEMS, rng, 1)[1]
            Astro:SpawnCollectible(item, player.Position)

            Astro.Data.RunReincarnation = false
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if collectibleType == Astro.Collectible.REINCARNATION then
            Astro.Data.RunReincarnation = true
        elseif Astro:Contain(REINCARNATION_ITEMS, collectibleType) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:Contain(REINCARNATION_ITEMS, collectibleType) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.REINCARNATION) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                local count = 0

                for _, item in ipairs(REINCARNATION_ITEMS) do
                    count = count + player:GetCollectibleNum(item)
                end

                player.Damage = player.Damage * (1 + REINCARNATION_DAMAGE_MULTIPLIER * count * player:GetCollectibleNum(Astro.Collectible.REINCARNATION))
            end
        end
    end
)

--#endregion

--#region Matryoshka

local CHEST_VARIANTS = {
    PickupVariant.PICKUP_CHEST,
    PickupVariant.PICKUP_LOCKEDCHEST,
    PickupVariant.PICKUP_REDCHEST,
    PickupVariant.PICKUP_BOMBCHEST,
    PickupVariant.PICKUP_ETERNALCHEST,
    PickupVariant.PICKUP_SPIKEDCHEST,
    PickupVariant.PICKUP_MIMICCHEST,
    PickupVariant.PICKUP_OLDCHEST,
    PickupVariant.PICKUP_WOODENCHEST,
    PickupVariant.PICKUP_MEGACHEST,
    PickupVariant.PICKUP_HAUNTEDCHEST,
    PickupVariant.PICKUP_MOMSCHEST
}

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data.Matryoshka = {
                RoomClearCount = 0,
                Damage = 0,
                FireDelay = 0,
                Speed = 0,
                Luck = 0
            }
        else
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(Astro.Collectible.MATRYOSHKA) then
                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                    player:EvaluateItems()
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    ---@param pickup EntityPickup
    function(_, pickup)
        if Astro:Contain(CHEST_VARIANTS, pickup.Variant) then
            local data = pickup:GetData()

            if data["isMatryoshka"] and pickup:GetSprite():IsPlaying("Open") then
                local isRun = false

                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)

                    if Astro.Data.Matryoshka ~= nil and player:HasCollectible(Astro.Collectible.MATRYOSHKA) then
                        if not isRun then
                            local rng = player:GetCollectibleRNG(Astro.Collectible.MATRYOSHKA)
                            local random = rng:RandomInt(4)
                            local matryoshkaNum = player:GetCollectibleNum(Astro.Collectible.MATRYOSHKA)

                            if random == 0 then
                                Astro.Data.Matryoshka.Damage = Astro.Data.Matryoshka.Damage + MATRYOSHKA_DAMAGE * matryoshkaNum
                            elseif random == 1 then
                                Astro.Data.Matryoshka.FireDelay = Astro.Data.Matryoshka.FireDelay + MATRYOSHKA_FIRE_DELAY * matryoshkaNum
                            elseif random == 2 then
                                Astro.Data.Matryoshka.Speed = Astro.Data.Matryoshka.Speed + MATRYOSHKA_SPEED * matryoshkaNum
                            elseif random == 3 then
                                Astro.Data.Matryoshka.Luck = Astro.Data.Matryoshka.Luck + MATRYOSHKA_LUCK * matryoshkaNum
                            end

                            if pickup.Variant == PickupVariant.PICKUP_CHEST then 
                                local spawnChance = Astro:HasCollectible(Astro.Collectible.CHUBBYS_TAIL) and MATRYOSHKA_WITH_CHUBBYS_TAIL_CHANCE or MATRYOSHKA_CHANCE

                                if rng:RandomFloat() < spawnChance then
                                    local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 1, pickup.Position, Vector(0, 0), nil)
                                    chest.SpriteScale = chest.SpriteScale * 0.75 -- TODO: 점점 더 작아지게
                                end
                            end

                            SFXManager():Play(chubbyUpSound, MATRYOSHKA_SOUND_VOLUME)

                            isRun = true
                        end

                        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                        player:EvaluateItems()
                    end
                end

                data["isMatryoshka"] = false
            elseif data["isMatryoshka"] == nil and not pickup:GetSprite():IsPlaying("Open") then
                data["isMatryoshka"] = true
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(Astro.Collectible.MATRYOSHKA) and Astro.Data.Matryoshka ~= nil then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + Astro.Data.Matryoshka.Damage
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = Astro:AddTears(player.MaxFireDelay, Astro.Data.Matryoshka.FireDelay)
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + Astro.Data.Matryoshka.Speed
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + Astro.Data.Matryoshka.Luck
            end
        end
    end
)


--#endregion

--#region Samsara

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = player:GetData()

            data["samsaraRemaining"] = (data["samsaraRemaining"] or 0) + player:GetCollectibleNum(Astro.Collectible.SAMSARA)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = player:GetData()

            if player:HasCollectible(Astro.Collectible.SAMSARA) and data["samsaraRemaining"] and data["samsaraRemaining"] > 0 and entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, false)

                data["samsaraRemaining"] = data["samsaraRemaining"] - 1
            end
        end
    end
)

--#endregion

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data.ManyuSet = 0
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:Contain(MANYU_SET_LIST, collectibleType) and Astro:IsFirstAdded(collectibleType) then
            Astro.Data.ManyuSet = Astro.Data.ManyuSet + 1

            if Astro.Data.ManyuSet == 3 then
                SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
                Game():GetHUD():ShowItemText("만유의 생멸", '')
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_GET_TRINKET,
    ---@param trinket TrinketType
    ---@param rng RNG
    function(_, trinket, rng)
        if Astro.Data and Astro.Data.ManyuSet and Astro.Data.ManyuSet >= 3 then
            if not Astro:IsGoldenTrinketType(trinket) then
                return trinket + Astro.GOLDEN_TRINKET_OFFSET
            end
        end
    end
)

---
local REINCARNATION_ITEMS = {
    CollectibleType.COLLECTIBLE_1UP,
    CollectibleType.COLLECTIBLE_LAZARUS_RAGS,
    CollectibleType.COLLECTIBLE_ANKH,
    AstroItems.Collectible.WANTED_SEEKER_OF_SINFUL_SPOIL
}

local REINCARNATION_DAMAGE_MULTIPLIER = 0.5

-- 마트료시카 공격력 증가량
local MATRYOSHKA_DAMAGE = 0.5

-- 마트료시카 연사 증가량
local MATRYOSHKA_FIRE_DELAY = 0.5

-- 마트료시카 이동 속도 증가량
local MATRYOSHKA_SPEED = 0.5

-- 마트료시카 행운 증가량
local MATRYOSHKA_LUCK = 0.5

-- 미니 상자가 등장할 확률 (0 ~ 1)
local MATRYOSHKA_CHEST_CHANCE = 0.5

-- 효과음 볼륨
local MATRYOSHKA_SOUND_VOLUME = 1.0
---

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.REINCARNATION = Isaac.GetItemIdByName("Reincarnation")
AstroItems.Collectible.MATRYOSHKA = Isaac.GetItemIdByName("Matryoshka")
AstroItems.Collectible.SAMSARA = Isaac.GetItemIdByName("Samsara")

local chubbyUpSound = Isaac.GetSoundIdByName('ChubbyUp')

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.REINCARNATION,
        "리인카네이션",
        "...",
        "다음 게임 시작 시 부활 아이템 중 하나가 소환됩니다." ..
        "#소지한 부활 아이템 하나당 공격력이 50%p 증가합니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.MATRYOSHKA,
        "마트료시카",
        "...",
        "상자를 열 때마다 공격력, 연사, 이동 속도, 행운 중 한 가지의 스텟이 0.5(고정) 증가됩니다." ..
        "#중첩 시 다음 증가량부터 적용됩니다." ..
        "#갈색 상자를 열 때 50% 확률로 미니 상자가 소환됩니다." ..
        "#{{ColorRed}}BUG: 상자에서 패시브, 액티브 아이템이 등장할 경우 스탯이 증가하지 않습니다."
    )

    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.SAMSARA,
        "삼사라",
        "...",
        "적 처치 시 {{Collectible522}}Telekinesis가 발동합니다. 방마다 한 번씩 발동합니다." ..
        "#중첩 시 여러 번 발동할 수 있습니다." ..
        "#Astrobirth 모드의 NextBan 시스템이 무효화됩니다."
    )
end

--#region Reincarnation

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued and AstroItems.Data.RunReincarnation then
            local player = Isaac.GetPlayer()
            local rng = player:GetCollectibleRNG(AstroItems.Collectible.REINCARNATION)

            local item = AstroItems:GetRandomCollectibles(REINCARNATION_ITEMS, rng, 1)[1]
            AstroItems:SpawnCollectible(item, player.Position)

            AstroItems.Data.RunReincarnation = false
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if collectibleType == AstroItems.Collectible.REINCARNATION then
            AstroItems.Data.RunReincarnation = true
        elseif AstroItems:Contain(REINCARNATION_ITEMS, collectibleType) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:Contain(REINCARNATION_ITEMS, collectibleType) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.REINCARNATION) then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                local count = 0

                for _, item in ipairs(REINCARNATION_ITEMS) do
                    count = count + player:GetCollectibleNum(item)
                end

                player.Damage = player.Damage * (1 + REINCARNATION_DAMAGE_MULTIPLIER * count * player:GetCollectibleNum(AstroItems.Collectible.REINCARNATION))
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

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            AstroItems.Data.Matryoshka = {
                RoomClearCount = 0,
                Damage = 0,
                FireDelay = 0,
                Speed = 0,
                Luck = 0
            }
        else
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
    
                if player:HasCollectible(AstroItems.Collectible.MATRYOSHKA) then
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

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PICKUP_UPDATE,
    ---@param pickup EntityPickup
    function(_, pickup)
        if AstroItems:Contain(CHEST_VARIANTS, pickup.Variant) then
            local data = pickup:GetData()

            if data["isMatryoshka"] and pickup:GetSprite():IsPlaying("Open") then
                local isRun = false

                for i = 1, Game():GetNumPlayers() do
                    local player = Isaac.GetPlayer(i - 1)

                    if AstroItems.Data.Matryoshka ~= nil and player:HasCollectible(AstroItems.Collectible.MATRYOSHKA) then
                        if not isRun then
                            local rng = player:GetCollectibleRNG(AstroItems.Collectible.MATRYOSHKA)
                            local random = rng:RandomInt(4)
                            local matryoshkaNum = player:GetCollectibleNum(AstroItems.Collectible.MATRYOSHKA)

                            if random == 0 then
                                AstroItems.Data.Matryoshka.Damage = AstroItems.Data.Matryoshka.Damage + MATRYOSHKA_DAMAGE * matryoshkaNum
                            elseif random == 1 then
                                AstroItems.Data.Matryoshka.FireDelay = AstroItems.Data.Matryoshka.FireDelay + MATRYOSHKA_FIRE_DELAY * matryoshkaNum
                            elseif random == 2 then
                                AstroItems.Data.Matryoshka.Speed = AstroItems.Data.Matryoshka.Speed + MATRYOSHKA_SPEED * matryoshkaNum
                            elseif random == 3 then
                                AstroItems.Data.Matryoshka.Luck = AstroItems.Data.Matryoshka.Luck + MATRYOSHKA_LUCK * matryoshkaNum
                            end

                            if pickup.Variant == PickupVariant.PICKUP_CHEST and rng:RandomFloat() < MATRYOSHKA_CHEST_CHANCE then
                                local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, 1, pickup.Position, Vector(0, 0), nil)
                                chest.SpriteScale = chest.SpriteScale * 0.75 -- TODO: 점점 더 작아지게
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

AstroItems:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:HasCollectible(AstroItems.Collectible.MATRYOSHKA) and AstroItems.Data.Matryoshka ~= nil then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + AstroItems.Data.Matryoshka.Damage
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = AstroItems:AddTears(player.MaxFireDelay, AstroItems.Data.Matryoshka.FireDelay)
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + AstroItems.Data.Matryoshka.Speed
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + AstroItems.Data.Matryoshka.Luck
            end
        end
    end
)


--#endregion

--#region Samsara

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = player:GetData()

            data["samsaraRemaining"] = (data["samsaraRemaining"] or 0) + player:GetCollectibleNum(AstroItems.Collectible.SAMSARA)
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    ---@param entityNPC EntityNPC
    function(_, entityNPC)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            local data = player:GetData()

            if player:HasCollectible(AstroItems.Collectible.SAMSARA) and data["samsaraRemaining"] and data["samsaraRemaining"] > 0 and entityNPC.Type ~= EntityType.ENTITY_FIREPLACE then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, false)

                data["samsaraRemaining"] = data["samsaraRemaining"] - 1
            end
        end
    end
)

--#endregion

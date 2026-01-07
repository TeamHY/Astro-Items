---

Astro.Collectible.MEGA_D8 = Isaac.GetItemIdByName("Mega D8")

local ITEM_ID = Astro.Collectible.MEGA_D8

local SPEED_MIN = 1.0

local SPEED_MAX = 2.0

local TEARS_MIN = 1.0

local TEARS_MAX = 2.0

local DAMAGE_MIN = 1.0

local DAMAGE_MAX = 2.0

local RANGE_MIN = 1.0

local RANGE_MAX = 2.0

local SHOTSPEED_MIN = 1.0

local SHOTSPEED_MAX = 2.0

local LUCK_MIN = 1.0

local LUCK_MAX = 2.0

---

if EID then
    local CRAFT_HINT = {
        ["ko_kr"] = "#{{DiceRoom}} {{ColorYellow}}주사위방{{CR}}에서 사용하여 변환",
        ["en_us"] = "#{{DiceRoom}} Can be transformed {{ColorYellow}}using it in the Dice Room{{CR}}"
    }
    Astro.EID:AddCraftHint(CollectibleType.COLLECTIBLE_D8, CRAFT_HINT)

    Astro.EID:AddCollectible(
        ITEM_ID,
        "대왕 8면체 주사위",
        "능력치 증폭기",  --임시 플레이버
        "사용 시 {{DamageSmall}}공격력, {{TearsSmall}}연사, {{RangeSmall}}사거리, {{SpeedSmall}}이동속도, {{ShotspeedSmall}}탄속, {{LuckSmall}}행운 중 하나를 선택하며;" ..
        "#{{ArrowGrayRight}} 선택한 능력치의 배율을 x1.0 ~ x2.0로 바꿉니다." ..
        "#!!! 같은 능력치에 재사용 시 기존 능력치 초기화"
    )

    Astro.EID:AddCollectible(
        ITEM_ID,
        "Mega D8",
        "",
        "On use, choose one stat to boost. The chosen stat is multiplied by x1.0 ~ x3.0. Using on the same stat resets the previous multiplier.",
        nil,
        "en_us"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectible CollectibleType
    ---@param rng RNG
    ---@param player EntityPlayer
    ---@param useFlags integer
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectible, rng, player, useFlags, activeSlot, varData)
        local room = Game():GetRoom()

        if room:GetType() == RoomType.ROOM_DICE and player:HasCollectible(CollectibleType.COLLECTIBLE_D8) then
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_D8)
            Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID, player.Position)
        end
    end,
    CollectibleType.COLLECTIBLE_D8
)

local megaUI = Astro.MegaUI:CreateInstance({
    anm2Path = "gfx/ui/mega-d8-ui.anm2",
    choiceCount = 6,
    itemId = ITEM_ID,
    onChoiceSelected = function(player, choice)
        local data = Astro.SaveManager.GetRunSave(player)
        local rng = player:GetCollectibleRNG(ITEM_ID)
        
        if choice == 1 then
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
            data.megaD8SpeedMultiplier = rng:RandomFloat() * (SPEED_MAX - SPEED_MIN) + SPEED_MIN
        elseif choice == 2 then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
            data.megaD8TearsMultiplier = rng:RandomFloat() * (TEARS_MAX - TEARS_MIN) + TEARS_MIN
        elseif choice == 3 then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
            data.megaD8DamageMultiplier = rng:RandomFloat() * (DAMAGE_MAX - DAMAGE_MIN) + DAMAGE_MIN
        elseif choice == 4 then
            player:AddCacheFlags(CacheFlag.CACHE_RANGE)
            player:EvaluateItems()
            data.megaD8RangeMultiplier = rng:RandomFloat() * (RANGE_MAX - RANGE_MIN) + RANGE_MIN
        elseif choice == 5 then
            player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
            player:EvaluateItems()
            data.megaD8ShotSpeedMultiplier = rng:RandomFloat() * (SHOTSPEED_MAX - SHOTSPEED_MIN) + SHOTSPEED_MIN
        elseif choice == 6 then
            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            player:EvaluateItems()
            data.megaD8LuckMultiplier = rng:RandomFloat() * (LUCK_MAX - LUCK_MIN) + LUCK_MIN
        end
    end
})

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    Astro.CallbackPriority.MULTIPLY,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        local data = Astro.SaveManager.GetRunSave(player)
        
        if cacheFlag == CacheFlag.CACHE_SPEED then
            local multiplier = data.megaD8SpeedMultiplier
            if multiplier then
                player.MoveSpeed = player.MoveSpeed * multiplier
            end
        elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
            local multiplier = data.megaD8TearsMultiplier
            if multiplier then
                player.MaxFireDelay = player.MaxFireDelay / multiplier
            end
        elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
            local multiplier = data.megaD8DamageMultiplier
            if multiplier then
                player.Damage = player.Damage * multiplier
            end
        elseif cacheFlag == CacheFlag.CACHE_RANGE then
            local multiplier = data.megaD8RangeMultiplier
            if multiplier then
                player.TearRange = player.TearRange * multiplier
            end
        elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            local multiplier = data.megaD8ShotSpeedMultiplier
            if multiplier then
                player.ShotSpeed = player.ShotSpeed * multiplier
            end
        elseif cacheFlag == CacheFlag.CACHE_LUCK then
            local multiplier = data.megaD8LuckMultiplier
            if multiplier then
                player.Luck = player.Luck * multiplier
            end
        end
    end
)

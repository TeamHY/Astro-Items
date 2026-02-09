Astro.Collectible.MEGA_D8 = Isaac.GetItemIdByName("Mega D8")
local ITEM_ID = Astro.Collectible.MEGA_D8

---

local SPEED_MIN = 1.0
local SPEED_MAX = 3.0
local SPEED_MAX_FIGHT = 2.0

local TEARS_MIN = 1.0
local TEARS_MAX = 3.0
local TEARS_MAX_FIGHT = 2.0

local DAMAGE_MIN = 1.0
local DAMAGE_MAX = 3.0
local DAMAGE_MAX_FIGHT = 2.0

local RANGE_MIN = 1.0
local RANGE_MAX = 3.0
local RANGE_MAX_FIGHT = 2.0

local SHOTSPEED_MIN = 1.0
local SHOTSPEED_MAX = 3.0
local SHOTSPEED_MAX_FIGHT = 2.0

local LUCK_MIN = 1.0
local LUCK_MAX = 3.0
local LUCK_MAX_FIGHT = 2.0

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_D8].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible406}}{{ColorYellow}}8면체 주사위{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible406}} {{ColorYellow}}D8{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.MEGA_D8, CRAFT_HINT)

            local maxString = Astro.IsFight and "2" or "3"

            Astro.EID:AddCollectible(
                ITEM_ID,
                "대왕 8면체 주사위",
                "작은 능력치가 맵다",
                "사용 시 {{DamageSmall}}공격력, {{TearsSmall}}연사, {{RangeSmall}}사거리, {{SpeedSmall}}이동속도, {{ShotspeedSmall}}탄속, {{LuckSmall}}행운 중 하나를 선택하며;" ..
                "#{{ArrowGrayRight}} 선택한 능력치의 배율을 x1 ~ x" .. maxString .."로 바꿉니다." ..
                "#!!! 같은 능력치에 재사용 시 기존 적용치 초기화"
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Mega D8", "",
                "Choose one of speed, tears, damage, range, shot speed, or luck:" ..
                "#The chosen stat is multiplied by 1x ~ " .. maxString .."x" ..
                "#!!! Using on the same stat resets the previous multiplier",
                nil, "en_us"
            )
        end
    end
)

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

        local finalMaxSpeed = Astro.IsFight and SPEED_MAX_FIGHT or SPEED_MAX
        local finalMaxTears = Astro.IsFight and TEARS_MAX_FIGHT or TEARS_MAX
        local finalMaxDamage = Astro.IsFight and DAMAGE_MAX_FIGHT or DAMAGE_MAX
        local finalMaxRange = Astro.IsFight and RANGE_MAX_FIGHT or RANGE_MAX
        local finalMaxShotspeed = Astro.IsFight and SHOTSPEED_MAX_FIGHT or SHOTSPEED_MAX
        local finalMaxLuck = Astro.IsFight and LUCK_MAX_FIGHT or LUCK_MAX
        
        if choice == 1 then
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
            data.megaD8SpeedMultiplier = rng:RandomFloat() * (finalMaxSpeed - SPEED_MIN) + SPEED_MIN
        elseif choice == 2 then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
            data.megaD8TearsMultiplier = rng:RandomFloat() * (finalMaxTears - TEARS_MIN) + TEARS_MIN
        elseif choice == 3 then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
            data.megaD8DamageMultiplier = rng:RandomFloat() * (finalMaxDamage - DAMAGE_MIN) + DAMAGE_MIN
        elseif choice == 4 then
            player:AddCacheFlags(CacheFlag.CACHE_RANGE)
            player:EvaluateItems()
            data.megaD8RangeMultiplier = rng:RandomFloat() * (finalMaxRange - RANGE_MIN) + RANGE_MIN
        elseif choice == 5 then
            player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
            player:EvaluateItems()
            data.megaD8ShotSpeedMultiplier = rng:RandomFloat() * (finalMaxShotspeed - SHOTSPEED_MIN) + SHOTSPEED_MIN
        elseif choice == 6 then
            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            player:EvaluateItems()
            data.megaD8LuckMultiplier = rng:RandomFloat() * (finalMaxLuck - LUCK_MIN) + LUCK_MIN
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

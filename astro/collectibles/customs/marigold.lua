Astro.Collectible.MARIGOLD = Isaac.GetItemIdByName("Marigold")
local ITEM_ID = Astro.Collectible.MARIGOLD

---

local SPAWN_COUNT = 3

local LEFT_CTRL_HOLD_DURATION = 30

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            local upgradeChance = string.format("%.f", Astro.UPGRADE_LIST[CollectibleType.COLLECTIBLE_MIDAS_TOUCH].Chance * 100)
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{ASTRO_EID_INDICATOR}} {{Collectible202}}{{ColorYellow}}미다스의 손길{{CR}} 등장 시 " .. upgradeChance .. "% 확률로 이 아이템으로 업그레이드됨",
                ["en_us"] = "#{{ASTRO_EID_INDICATOR}} " .. upgradeChance .. "% chance to upgrade to this item when {{Collectible202}} {{ColorYellow}}Midas' Touch{{CR}} appears"
            }
            Astro.EID:AddCraftHint(Astro.Collectible.MARIGOLD, CRAFT_HINT)

            Astro.EID:AddCollectible(
                ITEM_ID,
                "마리골드",
                "반드시 오고야 말 행복",
                "{{BossRoom}} 보스방 클리어 시 {{ColorGold}}황금{{CR}} 장신구 " .. SPAWN_COUNT .. "개를 소환합니다." ..
                "#{{ButtonRT}} (Ctrl)키를 누르고 있으면 소지중인 장신구를 흡수하며, 그 방의 장신구가 {{ColorGold}}황금{{CR}} 장신구로 바꿉니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Marigold", "",
                "Spawns " .. SPAWN_COUNT .. " {{ColorGold}}golden{{CR}} trinkets when clearing {{BossRoom}} boss room" ..
                "#{{Trinket}} Holding the drop button ({{ButtonRT}}) makes all trinkets in the room golden and absorbs held trinkets",
                nil, "en_us"
            )
        end
    end
)

Astro:AddUpgradeAction(
    function(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            local targets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_LIBRA, true, false)
            
            if #targets < 1 then
                return nil
            end

            return {
                targets = targets
            }
        end

        return nil
    end,
    function(player, data)
        for _, target in ipairs(data.targets) do
            target:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
            
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, target.Position, target.Velocity, nil)
            SFXManager():Play(Astro.SoundEffect.SCALES_OF_OBEDIENCE_APPEAR)

            player:RemoveCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE, true)
            player:AnimateCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)
        end
    end
)

local function ApplyGoldenEffect()
    -- Game():GetRoom():TurnGold()
end

local function HasMidasTouch()
    return Astro:HasCollectible(CollectibleType.COLLECTIBLE_MIDAS_TOUCH)
end

local function ExistMidasTouchEntity()
    return Isaac.CountEntities(nil, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_MIDAS_TOUCH) > 0
end

local function ChangeMidasTouchToMarigold()
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_MIDAS_TOUCH, true, false)

    for _, entity in ipairs(entities) do
        entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
    end

    for i = 1, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)

        local count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MIDAS_TOUCH, true)

        for _ = 1, count do
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_MIDAS_TOUCH, true)

            Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID, player.Position)
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_USE_PILL,
    ---@param pillEffect PillEffect
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    function(_, pillEffect, player, useFlags)
        if HasMidasTouch() or ExistMidasTouchEntity() then
            ApplyGoldenEffect()
            ChangeMidasTouchToMarigold()
        end
    end,
    PillEffect.PILLEFFECT_GULP
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
        if HasMidasTouch() or ExistMidasTouchEntity() then
            ApplyGoldenEffect()
            ChangeMidasTouchToMarigold()
        end
    end,
    CollectibleType.COLLECTIBLE_SMELTER
)

local function GetRandomGoldenTrinket()
    local trinketPool = Game():GetItemPool()
    local trinket = trinketPool:GetTrinket()
    return trinket | TrinketType.TRINKET_GOLDEN_FLAG
end

---@param player EntityPlayer
---@param count integer
local function SpawnGoldenTrinkets(player, count)
    for _ = 1, count do
        Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, GetRandomGoldenTrinket(), player.Position)
    end
end

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function()
        local room = Game():GetRoom()
        local roomType = room:GetType()
        
        if roomType == RoomType.ROOM_BOSS then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)
                local itemCount = player:GetCollectibleNum(ITEM_ID)
                
                if itemCount > 0 then
                    local trinketCount = SPAWN_COUNT * itemCount
                    SpawnGoldenTrinkets(player, trinketCount)
                end
            end
        end
    end
)

local dropActionPressTime = 0

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
            if not player:HasCollectible(ITEM_ID) then return end

            local input = Input.GetActionValue(ButtonAction.ACTION_DROP, 0)
            
            if input > 0 then
                dropActionPressTime = dropActionPressTime + 1

                if dropActionPressTime >= LEFT_CTRL_HOLD_DURATION * 2 then
                    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, -1, true, false)

                    for _, entity in ipairs(entities) do
                        local pickup = entity:ToPickup() ---@cast pickup -nil

                        if pickup.SubType & TrinketType.TRINKET_GOLDEN_FLAG == 0 then
                            pickup:Morph(
                                EntityType.ENTITY_PICKUP,
                                PickupVariant.PICKUP_TRINKET,
                                pickup.SubType | TrinketType.TRINKET_GOLDEN_FLAG
                            )

                            Astro:ScheduleForUpdate(
                                function()
                                    local sfx = SFXManager()
                                    sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 0.5)
                                    Game():SpawnParticles(pickup.Position, EffectVariant.GOLD_PARTICLE, 50, 10)
                                end,
                                4
                            )
                        end
                    end
                    
                    ApplyGoldenEffect()
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM)
                    
                    dropActionPressTime = 0
                end
            else
                dropActionPressTime = 0
            end
        end
    end
)

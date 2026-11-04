local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.SIGIL_OF_DUALITY = Isaac.GetItemIdByName("Sigil of Duality")

local STATUE_VARIANT = Isaac.GetEntityVariantByName("Duality Statue")
local STATUE_CORNER_OFFSET = Vector(20, 20)
local CONTACT_RADIUS = 28
local ENTER_DELAY = 1
local REWARD_DELAY = 30
local BOSS_SPAWN_OFFSET = Vector(0, -22)
local ENTRY_OFFSET = Vector(0, 120)
local STATUE_CHARGE_FRAMES = 45
local ITEM_OFFSET_X = 120

local BOSSES = {
    { Type = EntityType.ENTITY_URIEL, Variant = 0 },
    { Type = EntityType.ENTITY_URIEL, Variant = 1 },
    { Type = EntityType.ENTITY_GABRIEL, Variant = 0 },
    { Type = EntityType.ENTITY_GABRIEL, Variant = 1 },
}

local DEAL_DOOR_SOUNDS = {
    SoundEffect.SOUND_SATAN_ROOM_APPEAR,
    SoundEffect.SOUND_CHOIR_UNLOCK,
}

local BACKDROP_LAYERS = {
    [0] = "gfx/backdrop/duality_angel.png",
    [1] = "gfx/backdrop/duality_devil.png",
    [2] = "gfx/backdrop/duality_angel.png",
    [3] = "gfx/backdrop/duality_devil.png",
}

local DOOR_DUST_RADIUS = 30
local DUALITY_DOOR_SPRITESHEET = "gfx/backdrop/duality_door.png"
local DUALITY_DOOR_FLIPPED_SPRITESHEET = "gfx/backdrop/duality_door_flipped.png"
local DOOR_LAYER_COUNT = 5

local isEntering = false
local rewardTimer = 0

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.SIGIL_OF_DUALITY,
                "이중성의 인장",
                "",
                "이번 게임 보스방에서 {{DevilRoom}}악마방과 {{AngelRoom}}천사방 문이 열리지 않습니다." ..
                "#보스방 클리어 시 석상이 등장합니다." ..
                "#석상에게 접촉 시 천사 보스와 전투합니다." ..
                "#{{ArrowGrayRight}} 처치 시 각각의 거래 방식을 가진 {{AngelRoom}}천사방 아이템과 {{DevilRoom}}악마방 아이템이 등장합니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.SIGIL_OF_DUALITY,
                "Sigil of Duality", "",
                "{{DevilRoom}} Devil and {{AngelRoom}} Angel Room doors no longer open after boss fights this run" ..
                "#A statue appears when a boss room is cleared" ..
                "#Touching it starts a fight with an angel boss" ..
                "#{{ArrowGrayRight}} Defeating it reveals an {{AngelRoom}} Angel item and a {{DevilRoom}} Devil item, each with its own deal",
                nil, "en_us"
            )
        end
    end
)

Astro:AddUpgradeAction(
    function(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DUALITY)
            and (player:HasPlayerForm(PlayerForm.PLAYERFORM_ANGEL) or player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL))
        then
            return {}
        end

        return nil
    end,
    function(player, _)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_DUALITY)
        player:AnimateCollectible(CollectibleType.COLLECTIBLE_DUALITY)

        local pedestal = Astro:SpawnCollectible(Astro.Collectible.SIGIL_OF_DUALITY, player.Position)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, pedestal.Position, Vector.Zero, nil)
    end
)

---

local function IsSealed()
    return Astro.SaveManager.GetRunSave().sigilOfDualitySealed == true and not Game():IsGreedMode()
end

---@param door GridEntityDoor
---@return boolean
local function IsDealDoor(door)
    return door.TargetRoomType == RoomType.ROOM_DEVIL or door.TargetRoomType == RoomType.ROOM_ANGEL
end

---@param room Room
local function RemoveDealDoors(room)
    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(slot)

        if door and IsDealDoor(door) then
            room:RemoveDoor(slot)
        end
    end
end

---@param room Room
local function CloseDoors(room)
    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(slot)

        if door then
            door:Close(true)
        end
    end
end

---@param room Room
local function OpenDoors(room)
    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(slot)

        if door then
            door:Open()
        end
    end
end

---@param room Room
local function ClearRoom(room)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP or entity.Type == EntityType.ENTITY_SLOT or entity:ToNPC() then
            entity:Remove()
        end
    end

    for index = 0, room:GetGridSize() - 1 do
        local grid = room:GetGridEntity(index)

        if grid then
            local gridType = grid:GetType()

            if gridType ~= GridEntityType.GRID_DOOR and gridType ~= GridEntityType.GRID_WALL then
                room:RemoveGridEntity(index, 0, false)
            end
        end
    end
end

---@param collectibleType CollectibleType
---@return integer
local function GetDevilPrice(collectibleType)
    return Isaac.GetItemConfig():GetCollectible(collectibleType).DevilPrice
end

---@param room Room
local function SpawnDeals(room)
    local itemPool = Game():GetItemPool()
    local seed = room:GetSpawnSeed()
    local center = room:GetCenterPos()

    local angelItem = itemPool:GetCollectible(ItemPoolType.POOL_ANGEL, true, seed)
    local angelPedestal = Astro:SpawnCollectible(angelItem, center + Vector(-ITEM_OFFSET_X, 0), nil, true)
    angelPedestal.Price = PickupPrice.PRICE_ONE_HEART
    Astro.ForcePedestalPrice(
        angelPedestal,
        GetDevilPrice(angelItem) >= 2 and Astro.PickupPrice.PRICE_TWO_BROKEN_HEARTS or Astro.PickupPrice.PRICE_BROKEN_HEART
    )

    local devilItem = itemPool:GetCollectible(ItemPoolType.POOL_DEVIL, true, seed)
    local devilPedestal = Astro:SpawnCollectible(devilItem, center + Vector(ITEM_OFFSET_X, 0), nil, true)
    devilPedestal.Price = GetDevilPrice(devilItem) >= 2 and PickupPrice.PRICE_TWO_HEARTS or PickupPrice.PRICE_ONE_HEART
    devilPedestal.ShopItemId = -1
    devilPedestal.AutoUpdatePrice = true
end

---@param room Room
local function ApplyDualityDoors(room)
    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(slot)

        if door then
            local sprite = door:GetSprite()
            local spritesheet = door.Direction == Direction.DOWN and DUALITY_DOOR_FLIPPED_SPRITESHEET or DUALITY_DOOR_SPRITESHEET

            for layer = 0, DOOR_LAYER_COUNT - 1 do
                sprite:ReplaceSpritesheet(layer, spritesheet)
            end

            sprite:LoadGraphics()
        end
    end
end

local function RemoveDevilStatue()
    for _, devilStatue in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL)) do
        devilStatue:Remove()
    end
end

---@param room Room
local function SpawnDualityBoss(room)
    local rng = RNG()
    rng:SetSeed(room:GetSpawnSeed(), 35)

    local boss = BOSSES[rng:RandomInt(#BOSSES) + 1]

    Isaac.Spawn(boss.Type, boss.Variant, 0, room:GetCenterPos() + BOSS_SPAWN_OFFSET, Vector.Zero, nil)
end

local function SetUpDualityRoom()
    local room = Game():GetRoom()
    local player = Isaac.GetPlayer()

    isEntering = false
    rewardTimer = 0
    ClearRoom(room)
    Astro:SpawnBackdrop(BACKDROP_LAYERS)
    ApplyDualityDoors(room)
    RemoveDevilStatue()
    player.Position = room:GetCenterPos() + ENTRY_OFFSET
    player.Velocity = Vector.Zero
    SpawnDualityBoss(room)
    Astro.SaveManager.GetFloorSave().sigilOfDualityFighting = true
end

---@return boolean
local function IsBossAlive()
    for _, boss in ipairs(BOSSES) do
        for _, entity in ipairs(Isaac.FindByType(boss.Type, boss.Variant)) do
            if not entity:IsDead() then
                return true
            end
        end
    end

    return false
end

---@param room Room
local function SpawnRewards(room)
    local statue = Astro.Entity.DUALITY_STATUE

    Astro.SaveManager.GetFloorSave().sigilOfDualityFighting = nil
    ClearRoom(room)
    Isaac.Spawn(statue.Type, statue.Variant, statue.SubType, room:GetCenterPos(), Vector.Zero, nil)
    SpawnDeals(room)
    OpenDoors(room)
end

---@param room Room
local function UpdateDualityFight(room)
    if IsBossAlive() then
        rewardTimer = 0
        CloseDoors(room)
        return
    end

    rewardTimer = rewardTimer + 1
    CloseDoors(room)

    if rewardTimer >= REWARD_DELAY then
        SpawnRewards(room)
    end
end

local function EnterDualityRoom()
    isEntering = true
    Isaac.ExecuteCommand("goto s.devil")
end

---@param effect EntityEffect
local function BreakStatue(effect)
    SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)
    Game():ShakeScreen(15)
    effect:Remove()

    Astro.SaveManager.GetFloorSave().sigilOfDualityVisited = true
    Astro:ScheduleForUpdate(EnterDualityRoom, ENTER_DELAY)
end

---@param effect EntityEffect
local function StartStatueCharge(effect)
    effect:GetData().dualityCharge = 0
    SFXManager():Play(SoundEffect.SOUND_DOGMA_LIGHT_APPEAR)
end

---@param effect EntityEffect
local function UpdateStatueCharge(effect)
    local data = effect:GetData()
    data.dualityCharge = data.dualityCharge + 1

    local progress = data.dualityCharge / STATUE_CHARGE_FRAMES
    effect:GetSprite().Color = Color(1, 1, 1, 1, progress, progress, progress)

    if data.dualityCharge >= STATUE_CHARGE_FRAMES then
        BreakStatue(effect)
    end
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    function(_, _, _)
        Astro.SaveManager.GetRunSave().sigilOfDualitySealed = true
    end,
    Astro.Collectible.SIGIL_OF_DUALITY
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    CallbackPriority.EARLY,
    function(_)
        local room = Game():GetRoom()

        if IsSealed() and room:GetType() == RoomType.ROOM_BOSS then
            RemoveDealDoors(room)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    ---@param effect EntityEffect
    function(_, effect)
        local room = Game():GetRoom()

        if not IsSealed() or room:GetType() ~= RoomType.ROOM_BOSS then
            return
        end

        for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
            local door = room:GetDoor(slot)

            if door and IsDealDoor(door) and door.Position:Distance(effect.Position) <= DOOR_DUST_RADIUS then
                for _, sound in ipairs(DEAL_DOOR_SOUNDS) do
                    SFXManager():Stop(sound)
                end

                effect:Remove()
                return
            end
        end
    end,
    EffectVariant.DUST_CLOUD
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, _)
        isEntering = false
        rewardTimer = 0
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if isEntering then
            SetUpDualityRoom()
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        if not IsSealed() then
            return
        end

        local room = Game():GetRoom()

        if Astro.SaveManager.GetFloorSave().sigilOfDualityFighting
            and Game():GetLevel():GetCurrentRoomIndex() == GridRooms.ROOM_DEBUG_IDX
        then
            UpdateDualityFight(room)
            return
        end

        if room:GetType() ~= RoomType.ROOM_BOSS then
            return
        end

        RemoveDealDoors(room)

        if room:IsClear() and not Astro.SaveManager.GetFloorSave().sigilOfDualityVisited then
            local statue = Astro.Entity.DUALITY_STATUE

            if #Isaac.FindByType(statue.Type, statue.Variant, statue.SubType) == 0 then
                Astro:SpawnEntity(statue, room:GetTopLeftPos() + STATUE_CORNER_OFFSET)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if effect.SubType ~= Astro.Entity.DUALITY_STATUE.SubType or not IsSealed()
            or Game():GetRoom():GetType() ~= RoomType.ROOM_BOSS
        then
            return
        end

        if effect:GetData().dualityCharge then
            UpdateStatueCharge(effect)
        elseif #Isaac.FindInRadius(effect.Position, CONTACT_RADIUS, EntityPartition.PLAYER) > 0 then
            StartStatueCharge(effect)
        end
    end,
    STATUE_VARIANT
)

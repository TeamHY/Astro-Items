local isc = require("astro.lib.isaacscript-common")

require "astro.utils.knife-util"
require "astro.utils.noise"

Astro.TearModifier = require "astro.utils.tear-modifier"

--- From isaacscript-common
---
--- Helper function to get the player from a tear, laser, bomb, etc. Returns undefined if the entity
--- does not correspond to any particular player.
---
--- This function works by looking at the `Parent` and the `SpawnerEntity` fields (in that order). As
--- a last resort, it will attempt to use the `Entity.ToPlayer` method on the entity itself.
---@param entity Entity
---@return EntityPlayer | nil
function Astro:GetPlayerFromEntity(entity)
    if entity == nil then
        return nil
    end

    if entity.Parent ~= nil then
        local player = entity.Parent:ToPlayer()
        if (player ~= nil) then
            return player
        end

        local familiar = entity.Parent:ToFamiliar()
        if familiar ~= nil then
            return familiar.Player
        end
    end

    if entity.SpawnerEntity ~= nil then
        local player = entity.SpawnerEntity:ToPlayer()
        if player ~= nil then
            return player
        end

        local familiar = entity.SpawnerEntity:ToFamiliar()
        if familiar ~= nil then
            return familiar.Player
        end
    end

    return entity:ToPlayer()
end

---@param id TrinketType
---@param appendText string | table
---@param numbersToMultiply number | table | nil
---@param maxMultiplier number | table | nil
function Astro:AddGoldenTrinketDescription(id, appendText, numbersToMultiply, maxMultiplier)
    local data = EID.GoldenTrinketData[id]

    if data then
        if type(data) == "number" then
            EID:addGoldenTrinketMetadata(id, appendText, numbersToMultiply or data, maxMultiplier)
        else
            EID:addGoldenTrinketMetadata(id, appendText, numbersToMultiply or data.t, maxMultiplier or data.mult)
        end
    else
        EID:addGoldenTrinketMetadata(id, appendText, numbersToMultiply or 0, maxMultiplier)
    end

    if maxMultiplier and maxMultiplier > 4 then
        EID.GoldenTrinketData[id].mults = {maxMultiplier, maxMultiplier}
    end
end

---@generic T
---@param list T[]
---@param target T
function Astro:Contain(list, target)
    for _, value in ipairs(list) do
        if value == target then
            return true
        end
    end

    return false
end

---@param collectibles CollectibleType[]
---@param rng RNG
---@param count integer
---@param ignoreCollectible CollectibleType | CollectibleType[]?
---@param ignoreQuest boolean?
function Astro:GetRandomCollectibles(collectibles, rng, count, ignoreCollectible, ignoreQuest)
    ---@type CollectibleType[]
    local list = {}

    if ignoreQuest then
        local itemConfig = Isaac.GetItemConfig()

        for key, value in pairs(collectibles) do
            local isIgnore = value == ignoreCollectible

            if type(ignoreCollectible) == "table" then
                isIgnore = Astro:Contain(ignoreCollectible, value)
            end

            if not isIgnore and itemConfig:GetCollectible(value).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST then
                table.insert(list, value)
            end
        end
    else
        for _, value in ipairs(collectibles) do
            table.insert(list, value)
        end
    end

    ---@type CollectibleType[]
    local result = {}

    for _ = 1, count do
        if #list == 0 then
            break
        end

        local idx = rng:RandomInt(#list) + 1

        table.insert(result, list[idx])
        table.remove(list, idx)
    end

    return result
end

---해당 아이템을 모두 제거합니다. 제거한 아이템의 수를 반환합니다.
---@param player EntityPlayer
---@param type CollectibleType
---@return integer
function Astro:RemoveAllCollectible(player, type)
    local count = 0

    if player:HasCollectible(type) then
        for _ = 1, player:GetCollectibleNum(type) do
            player:RemoveCollectible(type)
            count = count + 1
        end
    end

    return count
end

---@param player EntityPlayer
---@param type TrinketType
function Astro:RemoveAllTrinket(player, type)
    local limit = 3
    local count = 0

    while player:HasTrinket(type) and count < limit do
        player:TryRemoveTrinket(type)
        count = count + 1
    end
end

---@param entityType integer
---@param entityVariant integer
---@param entitySubtype integer
---@param position Vector
---@return Entity
function Astro:Spawn(entityType, entityVariant, entitySubtype, position)
    local currentRoom = Game():GetLevel():GetCurrentRoom()

    return Isaac.Spawn(
        entityType,
        entityVariant,
        entitySubtype,
        currentRoom:FindFreePickupSpawnPosition(position, 0, true),
        Vector.Zero,
        nil
    )
end

---@param pillEffect PillEffect
---@param position Vector
---@return EntityPickup
function Astro:SpawnPill(pillEffect, position)
    local currentRoom = Game():GetLevel():GetCurrentRoom()
    local itemPool = Game():GetItemPool()
    local pillColor = itemPool:ForceAddPillEffect(pillEffect)

    return Isaac.Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_PILL,
        pillColor,
        currentRoom:FindFreePickupSpawnPosition(position, 0, true),
        Vector.Zero,
        nil
    ):ToPickup()
end

---@param cardType Card
---@param position Vector
---@return EntityPickup
function Astro:SpawnCard(cardType, position)
    local currentRoom = Game():GetLevel():GetCurrentRoom()

    return Isaac.Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_TAROTCARD,
        cardType,
        currentRoom:FindFreePickupSpawnPosition(position, 40, true),
        Vector.Zero,
        nil
    ):ToPickup()
end

---@param collectibleType CollectibleType
---@param position Vector
---@param optionsPickupIndex integer?
---@param isExactPosition boolean?
---@return EntityPickup
function Astro:SpawnCollectible(collectibleType, position, optionsPickupIndex, isExactPosition)
    local currentRoom = Game():GetLevel():GetCurrentRoom()

    local step = isExactPosition and 0 or 40

    local pickup =
        Isaac.Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_COLLECTIBLE,
        collectibleType,
        currentRoom:FindFreePickupSpawnPosition(position, step, true),
        Vector.Zero,
        nil
    ):ToPickup()

    if optionsPickupIndex then
        pickup.OptionsPickupIndex = optionsPickupIndex
    end

    return pickup
end

---@param trinketType TrinketType
---@param position Vector
---@return EntityPickup
function Astro:SpawnTrinket(trinketType, position)
    local currentRoom = Game():GetLevel():GetCurrentRoom()

    return Isaac.Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_TRINKET,
        trinketType,
        currentRoom:FindFreePickupSpawnPosition(position, 0, true),
        Vector.Zero,
        nil
    ):ToPickup()
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    ---@param isContinued boolean
    function(_, isContinued)
        if not isContinued then
            Astro.Data.CollectibleCount = {}
        end
    end
)

---아이템 최초 획득 시를 체크한다.
---TODO: 추후에 여러번 획득해도 동작하도록 변경할 예정이기 때문에 카운트를 저장한다.
---@param collectibleType CollectibleType
---@return boolean
function Astro:IsFirstAdded(collectibleType)
    local count = 0

    for index, value in ipairs(Astro.Data.CollectibleCount) do
        if value.id == collectibleType then
            count = value.count + 1
            Astro.Data.CollectibleCount[index].count = count
            break
        end
    end

    if count == 0 then
        table.insert(Astro.Data.CollectibleCount, { id = collectibleType, count = 1 })
        count = 1
    end

    return count == 1
end

--- Credit to Xalum(Retribution), _Kilburn and DeadInfinity
function Astro:AddTears(baseFiredelay, tearsUp)
    local currentTears = 30 / (baseFiredelay + 1)
    local newTears = currentTears + tearsUp
    local newFiredelay = math.max((30 / newTears) - 1, -0.75)

    return newFiredelay
end

---@param roomType RoomType
function Astro:DisplayRoom(roomType)
    local level = Game():GetLevel()
    local idx = level:QueryRoomTypeIndex(roomType, false, RNG())
    local room = level:GetRoomByIdx(idx)

    if room.Data.Type == roomType then
        room.DisplayFlags = room.DisplayFlags | RoomDescriptor.DISPLAY_BOX | RoomDescriptor.DISPLAY_ICON
        level:UpdateVisibility()
    end
end

---@param collectible CollectibleType
function Astro:HasCollectible(collectible)
    for i = 1, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)

        if player:HasCollectible(collectible) then
            return true
        end
    end

    return false
end

---@param collectible CollectibleType
function Astro:GetCollectibleNum(collectible)
    local count = 0

    for i = 1, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)

        count = count + player:GetCollectibleNum(collectible)
    end

    return count
end

---@param trinket TrinketType
function Astro:HasTrinket(trinket)
    for i = 1, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)

        if player:HasTrinket(trinket) then
            return true
        end
    end

    return false
end

---@param currentRoom Room
function Astro:CheckFirstVisitFrame(currentRoom)
    return currentRoom:GetFrameCount() <= 0 and currentRoom:IsFirstVisit()
end

---@param list any[]
---@param value any
---@return integer
function Astro:FindIndex(list, value)
    for i, v in ipairs(list) do
        if v == value then
            return i
        end
    end

    return -1
end

---@param index integer
function Astro:ConvertRoomIndexToPosition(index)
    local x = index % 13
    local y = math.floor(index / 13)

    return Vector(x, y)
end

---@param position Vector
function Astro:ConvertRoomPositionToIndex(position)
    if position.X < 0 or position.X > 12 or position.Y < 0 or position.Y > 12 then
        return -1
    end

    return position.Y * 13 + position.X
end

function Astro:IsDeathCertificateRoom()
    local level = Game():GetLevel()
    local roomName = level:GetCurrentRoomDesc().Data.Name

    if roomName == "Death Certificate" then
        return true
    end

    return false
end

--- Credit to EID
function Astro:IsCollectibleUnlocked(collectibleType)
    local itemConfig = Isaac.GetItemConfig()
    local item = itemConfig:GetCollectible(collectibleType)
    if item == nil then
        return false
    end

    local result = false

    if item.AchievementID == -1 or (item.Tags and item.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST) then
        result = true
        return true
    end

    if item.Hidden then
        result = false
        return false
    end

    if item.IsAvailable then
        result = item:IsAvailable()
    else
        result = true
    end
    return result
end

---@param value integer
---@param trinket TrinketType
---@return boolean
function Astro:CheckTrinket(value, trinket)
    if value == trinket or value - Astro.GOLDEN_TRINKET_OFFSET == trinket then
        return true
    end

    return false
end

local function RunUpdates(tab) --This is from Fiend Folio
    for i = #tab, 1, -1 do
        local f = tab[i]
        f.Delay = f.Delay - 1
        if f.Delay <= 0 then
            f.Func()
            table.remove(tab, i)
        end
    end
end

Astro.DelayedFuncs = {}

---Scheduled update from Fiend Folio
---@param foo function
---@param delay integer
---@param callback ModCallbacks?
function Astro:ScheduleForUpdate(foo, delay, callback)
    callback = callback or ModCallbacks.MC_POST_UPDATE
    if not Astro.DelayedFuncs[callback] then
        Astro.DelayedFuncs[callback] = {}
        Astro:AddCallback(
            callback,
            function()
                RunUpdates(Astro.DelayedFuncs[callback])
            end
        )
    end

    table.insert(Astro.DelayedFuncs[callback], {Func = foo, Delay = delay})
end

---@param worldPosition Vector
---@return Vector
function Astro:ToScreen(worldPosition)
    local room = Game():GetRoom()

    if room:IsMirrorWorld() then
        return room:WorldToScreenPosition(Vector(room:GetBottomRightPos().X + 60 - worldPosition.X, worldPosition.Y))
    end
    
    return room:WorldToScreenPosition(worldPosition)
end

function Astro:IsLatterStage()
    local level = Game():GetLevel()
    local stage = level:GetStage()

    if stage >= LevelStage.STAGE4_3 or (stage == LevelStage.STAGE4_1 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE) or (stage == LevelStage.STAGE4_2 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE) then
        return true
    end

    return false
end

---@generic T
---@param list table<integer, T>
---@param predicate fun(item: T): boolean
---@return table<integer, T>
function Astro:Filter(list, predicate)
    local result = {}

    for _, value in ipairs(list) do
        if predicate(value) then
            table.insert(result, value)
        end
    end

    return result
end

-- TODO: isc 함수들 자체 구현으로 변경해야 함

---@param player EntityPlayer
---@param trinketType TrinketType
function Astro:SmeltTrinket(player, trinketType)
    isc:smeltTrinket(player, trinketType)
end

---@param trinketType TrinketType
function Astro:IsGoldenTrinketType(trinketType)
    return isc:isGoldenTrinketType(trinketType)
end

function Astro:GetDoors()
    return isc:getDoors()
end

---

local MAX_ROW_NUM = 3

local ANIMATION_REPEAT_COUNT = 3

---



---@alias RerollConditionResult { reroll: boolean, newItem: CollectibleType, modifierName: string }

---@type (fun(selectedCollectible: CollectibleType): boolean | RerollConditionResult[])[]
Astro.RerollConditions = {}

local rerollTable = {}

---@param condition fun(selectedCollectible: CollectibleType): boolean | RerollConditionResult
function Astro:AddRerollCondition(condition)
    table.insert(Astro.RerollConditions, condition)
end

---@param selectedCollectible CollectibleType
---@return RerollConditionResult
local function CheckReroll(selectedCollectible)
    local result = {
        newItem = nil,
        reroll = false,
        modifierName = nil
    }

    for _, condition in ipairs(Astro.RerollConditions) do
        local conditionResult = condition(selectedCollectible)

        if type(conditionResult) == 'boolean' then
            result.reroll = conditionResult or result.reroll
        elseif type(conditionResult) == 'table' then
            local conditionResult = conditionResult --[[@as RerollConditionResult]]
            result.newItem = conditionResult.newItem or result.newItem
            result.reroll = conditionResult.reroll or result.reroll
            result.modifierName = conditionResult.modifierName or result.modifierName
        end
    end

    return result
end

Astro:AddCallback(
    ModCallbacks.MC_POST_GET_COLLECTIBLE,
    ---@param selectedCollectible CollectibleType
    ---@param itemPoolType ItemPoolType
    ---@param decrease boolean
    ---@param seed integer
    function(_, selectedCollectible, itemPoolType, decrease, seed)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.FALLEN_ORB) then
                local itemPool = Game():GetItemPool()
                local itemConfig = Isaac.GetItemConfig()
                local itemConfigitem = itemConfig:GetCollectible(selectedCollectible)

                local rng = RNG()
                rng:SetSeed(seed, 35)

                local rerollConditionResult = CheckReroll(selectedCollectible)

                if rerollConditionResult.reroll and itemConfigitem:HasTags(ItemConfig.TAG_QUEST) == false and selectedCollectible ~= CollectibleType.COLLECTIBLE_BREAKFAST then
                    local newCollectable = rerollConditionResult.newItem or itemPool:GetCollectible(itemPoolType, decrease, rng:Next())

                    if rerollTable[newCollectable] then
                        table.insert(rerollTable[newCollectable], selectedCollectible)
                    else
                        rerollTable[newCollectable] = { selectedCollectible }
                    end

                    print((rerollConditionResult.modifierName or '???') .. ": " .. selectedCollectible .. " -> " .. newCollectable)

                    return newCollectable
                end
            end
        end
    end
)

--#region Render

---@type {target: EntityPickup, sprite: Sprite, loops: number}[]
local rerollAnimationList = {}

---@param collectible CollectibleType
---@return Sprite
local function CreateRerollAnimationSprite(collectible)
    local itemConfig = Isaac.GetItemConfig()
    local itemConfigitem = itemConfig:GetCollectible(collectible)

    local sprite = Sprite()
    sprite:Load("gfx/reroll_collectible.anm2", true)
    sprite:ReplaceSpritesheet(0, itemConfigitem.GfxFileName)
    sprite:LoadGraphics()
    sprite:Play("Idle", true)

    return sprite
end

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        for i, value in ipairs(rerollAnimationList) do
            local sprite = value.sprite

            if not sprite:IsFinished("Idle") then
                sprite:Update()
            end
        end

        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            local pickup = entity:ToPickup()

            if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local collectible = pickup.SubType

                if rerollTable[collectible] then
                    for _, c in ipairs(rerollTable[collectible]) do
                        table.insert(rerollAnimationList, { target = pickup, sprite = CreateRerollAnimationSprite(c), loops = ANIMATION_REPEAT_COUNT })
                    end

                    rerollTable[collectible] = nil
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        local updatedAnimationList = {}

        ---@type { [integer]: {target: EntityPickup, sprite: Sprite, loops: number}[] }
        local groupedAnimations = {}

        for _, value in ipairs(rerollAnimationList) do
            local target = value.target

            if not target:Exists() then
                goto continue
            end

            if not groupedAnimations[target.InitSeed] then
                groupedAnimations[target.InitSeed] = {}
            end

            table.insert(groupedAnimations[target.InitSeed], value)

            ::continue::
        end

        for _, list in pairs(groupedAnimations) do
            for i, value in ipairs(list) do
                local target = value.target
                local sprite = value.sprite

                if target:Exists() then
                    if not sprite:IsFinished("Idle") then
                        local rowNum = math.floor((i - 1) / MAX_ROW_NUM) == math.floor(#list / MAX_ROW_NUM) and #list % MAX_ROW_NUM or MAX_ROW_NUM
                        local xOffset = (((i - 1) % MAX_ROW_NUM) + 0.5 - rowNum / 2) * 50
                        local yOffset = -((math.floor((i - 1) / MAX_ROW_NUM) * 50) + 80)
                        local position = Astro:ToScreen(target.Position + Vector(xOffset, yOffset))

                        sprite:Render(position, Vector(0, 0), Vector(0, 0))
                        table.insert(updatedAnimationList, value)
                    else
                        value.loops = value.loops - 1

                        if value.loops > 0 then
                            table.insert(updatedAnimationList, value)
                            sprite:Play("Idle", true)
                        end
                    end
                end
            end
        end

        rerollAnimationList = updatedAnimationList
    end
)

--#endregion

local MAX_ROW_NUM = 10

---@alias RerollConditionResult { reroll: boolean, newItem: CollectibleType }

---@type (fun(selectedCollectible: CollectibleType): boolean | RerollConditionResult[])[]
Astro.RerollConditions = {}

local rerollTable = {}

---@param selectedCollectible CollectibleType
---@return RerollConditionResult
local function CheckReroll(selectedCollectible)
    local result = {
        newItem = nil,
        reroll = false
    }

    for _, condition in ipairs(Astro.RerollConditions) do
        local conditionResult = condition(selectedCollectible)

        if type(conditionResult) == 'boolean' then
            result.reroll = conditionResult or result.reroll
        elseif type(conditionResult) == 'table' then
            local conditionResult = conditionResult --[[@as RerollConditionResult]]
            result.newItem = conditionResult.newItem or result.newItem
            result.reroll = conditionResult.reroll or result.reroll
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

                local isReroll = CheckReroll(selectedCollectible)

                if isReroll and itemConfigitem:HasTags(ItemConfig.TAG_QUEST) == false and selectedCollectible ~= CollectibleType.COLLECTIBLE_BREAKFAST then
                    local newCollectable = itemPool:GetCollectible(itemPoolType, decrease, rng:Next())

                    if rerollTable[newCollectable] then
                        table.insert(rerollTable[newCollectable], selectedCollectible)
                    else
                        rerollTable[newCollectable] = { selectedCollectible }
                    end

                    return newCollectable
                end
            end
        end
    end
)

--#region Render

---@type {target: EntityPickup, sprite: Sprite}[]
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
    sprite:SetLastFrame()

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
                    table.insert(rerollAnimationList, { target = pickup, sprite = CreateRerollAnimationSprite(collectible) })
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i, value in ipairs(rerollAnimationList) do
            local target = value.target
            local sprite = value.sprite

            local rowNum = math.floor((i - 1) / MAX_ROW_NUM) == math.floor(#rerollAnimationList / MAX_ROW_NUM) and #rerollAnimationList % MAX_ROW_NUM or MAX_ROW_NUM
            local xOffset = (((i - 1) % MAX_ROW_NUM) + 0.5 - rowNum / 2) * 50
            local yOffset = -((math.floor((i - 1) / MAX_ROW_NUM) * 50) + 60)
            local position = Astro:ToScreen(target.Position + Vector(xOffset, yOffset))

            if sprite:IsFinished("Idle") then
                table.remove(rerollAnimationList, i)
            else
                sprite:Render(position, Vector(0, 0), Vector(0, 0))
            end
        end
    end
)

--#endregion

---

local MAX_ROW_NUM = 3

local ANIMATION_REPEAT_COUNT = 3

---

local UnusedCollectibleChecker = {
    [Astro.Collectible.RITE_OF_ARAMESIR] = true,
}

---@type {target: GridEntityTrapDoor?, sprite: Sprite, loops: number}[]
local unusedAnimationList = {}

---@param collectible CollectibleType
---@return Sprite
local function CreateUnusedAnimationSprite(collectible)
    local itemConfig = Isaac.GetItemConfig()
    local itemConfigitem = itemConfig:GetCollectible(collectible)

    local sprite = Sprite()
    sprite:Load("gfx/unused_collectible.anm2", true)
    sprite:ReplaceSpritesheet(0, itemConfigitem.GfxFileName)
    sprite:LoadGraphics()
    sprite:Play("Idle", true)

    return sprite
end

local function FindTrapdoor()
    local room = Game():GetRoom()
    local width = room:GetGridWidth()
    local height = room:GetGridHeight()
    
    for i = 0, width * height - 1 do
        local gridEntity = room:GetGridEntity(i)

        if gridEntity and gridEntity:GetType() == GridEntityType.GRID_TRAPDOOR then
            return gridEntity
        end
    end

    return nil
end

local function RefreshAnimation()
    unusedAnimationList = {}

    local trapdoor = FindTrapdoor()

    if not trapdoor then return end

    local itemConfig = Isaac.GetItemConfig()

    for i = 1, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)
    
        for j = 0, 3 do
            local activeItem = player:GetActiveItem(j)
            local configData = itemConfig:GetCollectible(activeItem)

            if UnusedCollectibleChecker[activeItem] and configData.MaxCharges <= player:GetActiveCharge(j) then
                table.insert(unusedAnimationList, { target = trapdoor, sprite = CreateUnusedAnimationSprite(activeItem), loops = ANIMATION_REPEAT_COUNT })
            end
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        RefreshAnimation()
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        Astro:ScheduleForUpdate(
            function()
                RefreshAnimation()
            end,
            1
        )
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        for i, value in ipairs(unusedAnimationList) do
            local sprite = value.sprite

            if not sprite:IsFinished("Idle") then
                sprite:Update()
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        local updatedAnimationList = {}

        for i, value in ipairs(unusedAnimationList) do
            local target = value.target
            local sprite = value.sprite

            if target then
                if not sprite:IsFinished("Idle") then
                    local rowNum = math.floor((i - 1) / MAX_ROW_NUM) == math.floor(#unusedAnimationList / MAX_ROW_NUM) and #unusedAnimationList % MAX_ROW_NUM or MAX_ROW_NUM
                    local xOffset = (((i - 1) % MAX_ROW_NUM) + 0.5 - rowNum / 2) * 50
                    local yOffset = -((math.floor((i - 1) / MAX_ROW_NUM) * 50) + 40)
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

        unusedAnimationList = updatedAnimationList
    end
)

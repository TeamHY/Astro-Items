local isc = require("astro.lib.isaacscript-common")

local PENALTY_DEATHS_HEAD_COUNT = 2 -- 빠가지 소환 개수

local PENALTY_DEATHS_HEAD_CHANCE = 1 -- 빠가지 소환 확률

local PENALTY_BROKEN_HEARTS = 0 -- 뼈 심장 추가 개수

-- 패널티 피격 시 차지 감소
local PENALTY_ACTIVE_ITEMS = {
    [CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS] = 1, -- ex) 피격 시 2 감소
}

-- 패널티 피격 시 아이템 제거
local PENALTY_REMOVE_ITEMS = {
    collectible = {
        CollectibleType.COLLECTIBLE_LIBRA,
        CollectibleType.COLLECTIBLE_DEAD_CAT,
        CollectibleType.COLLECTIBLE_TAURUS,
        CollectibleType.COLLECTIBLE_COMPASS,
        CollectibleType.COLLECTIBLE_TREASURE_MAP,
        CollectibleType.COLLECTIBLE_BLUE_MAP,
        CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
        CollectibleType.COLLECTIBLE_SPELUNKER_HAT,
        CollectibleType.COLLECTIBLE_MIND,
        CollectibleType.COLLECTIBLE_GOAT_HEAD,
        CollectibleType.COLLECTIBLE_EUCHARIST,
        CollectibleType.COLLECTIBLE_SOL,
        Astro.Collectible.BIRTHRIGHT_ISAAC,
        Astro.Collectible.UNHOLY_MANTLE,
        Astro.Collectible.OMEGA_321,
        Astro.Collectible.BIRTHRIGHT_THE_LOST,
        Astro.Collectible.BIRTHRIGHT_TAINTED_LOST,
        Astro.Collectible.GUPPY_PART,
        Astro.Collectible.PUZZLE_DICE,
        Astro.Collectible.POWER_ROCK_BOTTOM,
    },
    trinket = {
        TrinketType.TRINKET_JAW_BREAKER,
    }
}
Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if not Astro.IsFight then return end

        if EID then
            for item, penalty in pairs(PENALTY_ACTIVE_ITEMS) do
                EID:addDescriptionModifier(
                    "AstroPenaltyActive" .. item,
                    function(descObj)
                        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == item then
                            return true
                        end
                    end,
                    function(descObj)
                        EID:appendToDescription(descObj, "#{{ColorRed}}패널티 피격 시 차지가 " .. penalty .. " 감소됩니다.")
                        return descObj
                    end
                )
            end

            for _, item in ipairs(PENALTY_REMOVE_ITEMS.collectible) do
                EID:addDescriptionModifier(
                    "AstroPenaltyRemoveCollectible" .. item,
                    function(descObj)
                        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == item then
                            return true
                        end
                    end,
                    function(descObj)
                        EID:appendToDescription(descObj, "#{{ColorRed}}패널티 피격 시 제거됩니다.")
                        return descObj
                    end
                )
            end

            for _, item in ipairs(PENALTY_REMOVE_ITEMS.trinket) do
                EID:addDescriptionModifier(
                    "AstroPenaltyRemoveTrinket" .. item,
                    function(descObj)
                        if descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_TRINKET and descObj.ObjSubType == item then
                            return true
                        end
                    end,
                    function(descObj)
                        EID:appendToDescription(descObj, "#{{ColorRed}}패널티 피격 시 제거됩니다.")
                        return descObj
                    end
                )
            end
        end
    end
)


local function CheckBossRoom()
    local level = Game():GetLevel()
    local stage = level:GetAbsoluteStage()
    local currentRoom = level:GetCurrentRoom()
    local currentRoomDesc = Game():GetLevel():GetCurrentRoomDesc()

    if currentRoom:GetType() ~= RoomType.ROOM_BOSS then
        return false
    end

    if currentRoom:IsClear() then
        return false
    end

    if stage == LevelStage.STAGE3_2 and currentRoom:GetBossID() == 6 then
        return true -- 엄마 발
    elseif stage == LevelStage.STAGE4_3 then
        return true -- 허쉬
    elseif stage == LevelStage.STAGE5 then
        return true -- 성당 / 저승
    elseif stage == LevelStage.STAGE6 then
        return true -- 체스트 / 다크룸 / 메가 사탄
    elseif stage == LevelStage.STAGE7 then
        return true -- 델리리움
    elseif currentRoom:GetBossID() == 88 then
        return true -- 마더
    elseif currentRoomDesc.Data.Name == "Beast Room" then
        return true -- 비스트
    end

    return false
end

local deletedItems = {}
local notiFont = Font()
notiFont:Load(Astro.ModPath .. "resources/font/eid_korean_galmoori9.fnt")

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        if not Astro.IsFight then return end

        -- 패널티 액티브 아이템 처리
        for item, penalty in pairs(PENALTY_ACTIVE_ITEMS) do
            if player:HasCollectible(item) then
                for i = 0, ActiveSlot.SLOT_POCKET2 do
                    if player:GetActiveItem(i) == item then
                        local charge = player:GetActiveCharge(i)

                        if charge > 0 then
                            player:SetActiveCharge(math.max(0, charge - penalty), i)
                        end
                    end
                end
            end
        end

        local yOffset = 0

        for _, item in ipairs(PENALTY_REMOVE_ITEMS.collectible) do
            if player:HasCollectible(item) then
                yOffset = yOffset + 1
                table.insert(deletedItems, { var = 100, id = item, time = Game():GetFrameCount() + yOffset })
                Astro:RemoveAllCollectible(player, item)
            end
        end

        for _, item in ipairs(PENALTY_REMOVE_ITEMS.trinket) do
            if player:HasTrinket(item) then
                yOffset = yOffset + 1
                table.insert(deletedItems, { var = 350, id = item, time = Game():GetFrameCount() + yOffset })
                Astro:RemoveAllTrinket(player, item)
            end
        end

        if CheckBossRoom() then
            if player:GetCollectibleRNG(Astro.Collectible.BIRTHRIGHT_EDEN_B):RandomFloat() <= PENALTY_DEATHS_HEAD_CHANCE then
                for i = 1, PENALTY_DEATHS_HEAD_COUNT do
                    Astro:Spawn(EntityType.ENTITY_DEATHS_HEAD, 0, 0, player.Position)
                end
            end

            if not (Astro.IsFight and Astro:IsLatterStage()) then
                player:AddBrokenHearts(PENALTY_BROKEN_HEARTS)
            end
        end
    end
)


------ 제거 알림 ------
local pixelSprite = Sprite()
pixelSprite:Load("gfx/ui/pixel.anm2", true)
pixelSprite:SetFrame("Idle", 0)

local function drawRect(x, y, w, h, a)
    pixelSprite.Scale = Vector(w, h)
    pixelSprite.Color = Color(0, 0, 0, a)
    pixelSprite:Render(Vector(x, y))
end

---@param item table
---@param yOffset integer
---@return boolean
local function renderDeletedItem(item, yOffset)    -- by reshaken team
    local itemName = EID:getObjectName(5, item.var, item.id)
    local startingFrame = item.time
    local currentFrame = Game():GetFrameCount()
    local duration = currentFrame - startingFrame

    if duration >= 150 then
        return true
    end

    local baseXPos = Isaac.GetScreenWidth()
    local baseYPos = 70
    local baseScale = 1
    local alpha = 1

    if duration <= 10 then
        local percent = duration / 10
        local movementPercent = isc:easeOutSine(percent)

        local XOffset = isc:lerp(20, 0, movementPercent)
        baseXPos = baseXPos + XOffset

        alpha = isc:lerp(0, 1, percent)
    end

    if 150 - duration <= 40 then
        local percent = (150 - duration) / 40

        alpha = isc:lerp(0, 1, percent)
    end

    local scaleMulti = Isaac.GetScreenPointScale()
    if scaleMulti == 1 then
        baseScale = 1
    elseif scaleMulti == 2 then
        baseScale = 0.5
    elseif scaleMulti == 3 then
        baseScale = 2/3
    else
        baseScale = 0.75
    end

    baseYPos = baseYPos + yOffset * baseScale
    pos = Vector(baseXPos, baseYPos) + Game().ScreenShakeOffset

    local output = itemName .. " 제거됨"
    local stringWidth = notiFont:GetStringWidthUTF8(output)
    local stringHeight = notiFont:GetBaselineHeight()
    
    drawRect(
        pos.X - 480 + (400 - (stringWidth + 3) * baseScale),
        pos.Y - (1.5 * baseScale),
        (stringWidth + 6) * baseScale,
        (stringHeight + 6) * baseScale,
        alpha * 0.75
    )

    notiFont:DrawStringScaledUTF8(
        output,
        pos.X - 480, pos.Y,
        baseScale, baseScale,
        KColor(1, 0.5, 0.5, alpha),
        400,
        false
    )

    return false
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function()
        if #deletedItems > 0 then
            for idx, item in pairs(deletedItems) do
                if renderDeletedItem(item, idx * 15) then
                    table.remove(deletedItems, idx)
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function()
        deletedItems = {}
    end
)
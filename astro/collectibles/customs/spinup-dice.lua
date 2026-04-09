-- https://steamcommunity.com/sharedfiles/filedetails/?id=2815597129

Astro.Collectible.SPINUP_DICE = Isaac.GetItemIdByName("Spinup Dice")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.SPINUP_DICE,
                "스핀업 주사위",
                "+1",
                "사용 시 그 방의 아이템을 코드 뒷번호의 아이템으로 바꿉니다." ..
                "#!!! 일부 아이템은 등장하지 않습니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.SPINUP_DICE,
                "Spinup Dice", "",
                "Rerolls all items in the room by increasing their internal ID by one",
                nil, "en_us"
            )
        end
    end
)


------ EID ------
---@param collectibleID CollectibleType
---@return CollectibleType
local function getSpindownResult(collectibleID)
	if collectibleID <= 0 or collectibleID > 4294960000 then return 0 end

	local newID = collectibleID
	local attempts = 0
    local itemCfg = Isaac.GetItemConfig()

	repeat
		newID = newID - 1
		attempts = attempts + 1
	until itemCfg:GetCollectible(newID) and not itemCfg:GetCollectible(newID).Hidden or newID == CollectibleType.COLLECTIBLE_NULL or attempts > 20
	
    return newID
end

---@param collectibleID CollectibleType
---@return CollectibleType
local function getSpinupResult(collectibleID)
	if collectibleID <= 0 or collectibleID > 4294960000 then return 0 end

	local newID = collectibleID
	local attempts = 0
    local itemCfg = Isaac.GetItemConfig()

	repeat
		newID = newID + 1
		attempts = attempts + 1

        if newID == CollectibleType.COLLECTIBLE_DADS_NOTE then
            newID = newID + 1
        end
	until itemCfg:GetCollectible(newID) and not itemCfg:GetCollectible(newID).Hidden or attempts > 20
    
	return newID
end

local function TabCallback(descObj)
	if EID.TabPreviewID == 0 then return descObj end

	EID.TabDescThisFrame = true
	EID.inModifierPreview = true

	local descEntry = EID:getDescriptionObj(5, 100, EID.TabPreviewID)
	EID.inModifierPreview = false
	EID.TabPreviewID = 0
	descEntry.Entity = descObj.Entity

	return descEntry
end

local function TabConditions(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 100 and EID:PlayersActionPressed(EID.Config["BagOfCraftingToggleKey"]) and not EID.inModifierPreview then
        for i = 0, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.SPINUP_DICE) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(Astro.Collectible.SPINUP_DICE)]) then
                return true
            end
        end
    end
    
	EID.TabPreviewID = 0
	return false
end

local function SpinupModifierCondition(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 100 then
        for i = 0, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.SPINUP_DICE) or player:HasCollectible(Astro.Collectible.QUBIT_DICE) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(Astro.Collectible.SPINUP_DICE)]) then
                return true
            end
        end
    end
end

local function SpinupModifierCallback(descObj)
    local playerID, icon, hasCarBattery

    -- items check
    for i = 0, Game():GetNumPlayers() do
        local player = Isaac.GetPlayer(i - 1)

        if player:HasCollectible(Astro.Collectible.SPINUP_DICE) or player:HasCollectible(Astro.Collectible.QUBIT_DICE) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(Astro.Collectible.SPINUP_DICE)]) then
            playerID = i - 1
            icon = "#{{Collectible" .. Astro.Collectible.SPINUP_DICE .. "}} :"

            break
        end
    end

    if playerID then
        local refID = descObj.ObjSubType
        if refID == CollectibleType.COLLECTIBLE_DADS_NOTE then return descObj end
        EID:appendToDescription(descObj, icon)

        hasCarBattery = Isaac.GetPlayer(playerID):HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)

        local firstID = 0
        for i = 1, EID.Config["SpindownDiceResults"] do
            local spinnedID = getSpinupResult(refID)

            if hasCarBattery then
                refID = spinnedID
                spinnedID = getSpinupResult(refID)
            end
            
            refID = spinnedID

            if refID < 4294960000 then
                local loopsBackString = (Options.Language == "kr" or REPKOR) and "{{Collectible1}}로 돌아감" or "Loops back to {{Collectible1}}" 

                if EID.itemConfig:GetCollectible(refID) == nil then EID:appendToDescription(descObj, loopsBackString)
                    break
                else
                    if i == 1 then
                        firstID = refID
                    end
                    EID:appendToDescription(descObj, "{{Collectible"..refID.."}}")
                    --if EID.itemUnlockStates[refID] == false then EID:appendToDescription(descObj, "?") end

                    if EID.Config["SpindownDiceDisplayID"] then
                        EID:appendToDescription(descObj, "/".. refID)
                    end
                    if EID.Config["SpindownDiceDisplayName"] then
                        EID:appendToDescription(descObj, "/".. EID:getObjectName(5, 100, refID))

                        if i ~= EID.Config["SpindownDiceResults"] then
                            EID:appendToDescription(descObj, "#{{Blank}}")
                        end
                    end

                    if i ~= EID.Config["SpindownDiceResults"] then
                        EID:appendToDescription(descObj, " ->")
                    end
                end
            end
        end

        if hasCarBattery then
            EID:appendToDescription(descObj, " " .. EID:ReplaceVariableStr(EID:getDescriptionEntry("ResultsWithX"), 1, "{{Collectible356}}"))
        end

        if firstID ~= 0 and EID.TabPreviewID == 0 then
            EID.TabPreviewID = firstID

            if not EID.inModifierPreview then
                EID:appendToDescription(descObj, "#{{Blank}} " .. EID:getDescriptionEntry("FlipItemToggleInfo"))
            end
        end

        return descObj
    end
end

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID and EID.Config["SpindownDiceResults"] > 0 then
            EID:addDescriptionModifier("Spinup Modifier", SpinupModifierCondition, SpinupModifierCallback)
            EID:addDescriptionModifier("Spinup Tab Previews", TabConditions, TabCallback)
        end
    end
)


------ 로직 ------
--[[ checklist = {
    [42] = 44,   [58] = 60,   [60] = 62,   [234] = 236,
    [586] = 588, [612] = 614, [619] = 621, [629] = 631,
    [647] = 649, [655] = 657, [661] = 663, [665] = 667,
    [713] = 716, [717] = 719
}]]

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local pData = Astro:GetPersistentPlayerData(playerWhoUsedItem)
        pData.spinupItems = {}

        local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        for _, entity in ipairs(entities) do
            if entity.SubType ~= 0 and entity.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE and entity.SubType < 4294960000 then
                local item = entity:ToPickup()
                local nextid

                if item then
                    nextid = getSpinupResult(getSpinupResult(item.SubType))

                    if getSpindownResult(nextid) == CollectibleType.COLLECTIBLE_DADS_NOTE then
                        table.insert(pData.spinupItems, { index = item.Index, id = item.SubType, reason = "아빠의 쪽지" })
                    elseif item.SubType == getSpindownResult(Astro:GetMaxCollectibleID()) then
                        table.insert(pData.spinupItems, { index = item.Index, id = item.SubType, reason = "마지막 이전 아이템" })
                    elseif item.SubType == Astro:GetMaxCollectibleID() then
                        table.insert(pData.spinupItems, { index = item.Index, id = item.SubType, reason = "마지막 아이템" })
                    end

                    item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, nextid, true)
                end
            end
        end
        playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_SPINDOWN_DICE, UseFlag.USE_NOANIM)
        SFXManager():Play(910)

        entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        for _, entity in ipairs(entities) do
            local item = entity:ToPickup()
            local adjustID
            
            for _, originItem in ipairs(pData.spinupItems) do
                if item.Index == originItem.index then
                    if entity.SubType == CollectibleType.COLLECTIBLE_DADS_NOTE and originItem.reason == "아빠의 쪽지" then
                        adjustID = getSpinupResult(originItem.id)
                        item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, adjustID, true)
                    elseif originItem.id == getSpindownResult(Astro:GetMaxCollectibleID()) and originItem.reason == "마지막 이전 아이템" then
                        adjustID = Astro:GetMaxCollectibleID()
                        item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, adjustID, true)
                    elseif originItem.id == Astro:GetMaxCollectibleID() and originItem.reason == "마지막 아이템" then
                        adjustID = CollectibleType.COLLECTIBLE_SAD_ONION
                        item:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, adjustID, true)
                    end
                end
            end
        end

        pData.spinupItems = {}
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.SPINUP_DICE
)


------ 프리뷰 ------
local curseStringTable = {
    ["en"] = "Curse of the Blind!",
    ["jp"] = "盲目の呪い",
    ["kr"] = "눈먼 자의 저주!",
    ["zh"] = "致盲诅咒！",
    ["ru"] = "Проклятие Слепоты!",
    ["de"] = "Fluch der Blinden!",
    ["es"] = "Maldición del Ciego",
    ["fr"] = "Fléau de Cécité !"
}

local spriteCache = {}

local function RenderCollectible(entity)
    local nextCollectibleSubType = getSpinupResult(entity.SubType)
    if entity.SubType == CollectibleType.COLLECTIBLE_DADS_NOTE then
        return
    elseif entity.SubType == Astro:GetMaxCollectibleID() then
        nextCollectibleSubType = CollectibleType.COLLECTIBLE_SAD_ONION
    elseif nextCollectibleSubType == nil then
        return
    end
    
    local itemConfig = Isaac.GetItemConfig():GetCollectible(nextCollectibleSubType)
    if itemConfig ~= nil then
        descriptor = itemConfig.GfxFileName

        local itemSprite
        if spriteCache[descriptor] == nil then
            itemSprite = Sprite()
            itemSprite:Load("gfx/005.100_Collectible.anm2", true)
            itemSprite:ReplaceSpritesheet(1, itemConfig.GfxFileName)
            itemSprite:LoadGraphics()
            itemSprite.Color = Color(1, 1, 1, 0.45)
            itemSprite:SetFrame("Idle", 8)
            itemSprite.Scale = Vector(0.4, 0.4)
            
            spriteCache[descriptor] = itemSprite
        else
            itemSprite = spriteCache[descriptor]
        end
        
        local adjustedPosition = Vector.Zero
        if entity:ToPickup():IsShopItem() then 
            adjustedPosition = entity.Position - Vector(-22, 20)
        else
            adjustedPosition = entity.Position - Vector(-22, 38)
        end
        
        itemSprite:Render(Astro:ToScreen(adjustedPosition), Vector(0, 0), Vector(0, 0))
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        if not Astro:HasCollectible(Astro.Collectible.SPINUP_DICE) then return end
        if Astro.Data["SpinupPreview"] == 0 then return end

        local curseName = Game():GetLevel():GetCurseName()
        if curseName ~= nil and curseName == curseStringTable[Options.Language] then return end
        
        local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        if #pickups > 0 then
            for i, entity in ipairs(pickups) do
                RenderCollectible(entity)
            end
        end
    end
)
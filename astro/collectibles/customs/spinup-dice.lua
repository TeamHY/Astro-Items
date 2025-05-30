-- https://steamcommunity.com/sharedfiles/filedetails/?id=2815597129

Astro.Collectible.SPINUP_DICE = Isaac.GetItemIdByName("Spinup Dice")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SPINUP_DICE,
        "스핀업 주사위",
        "+1",
        "사용 시 그 방의 아이템을 코드 뒷번호의 아이템으로 바꿉니다.#!!! 일부 아이템은 등장하지 않습니다."
    )
end

local function GetSpinupResult(collectibleID)
	if collectibleID <= 0 or collectibleID > 4294960000 then return 0 end
	local newID = collectibleID
	local attempts = 0
	repeat
		newID = newID + 1
		attempts = attempts + 1

        --if it's dad's note, skip it
        if newID == 668 then newID = newID + 1 end
	until (EID.itemConfig:GetCollectible(newID) and not Isaac.GetItemConfig():GetCollectible(newID).Hidden == true) or attempts > 10
	return newID
end

local function TabCallback(descObj)
	if EID.TabPreviewID == 0 then
        return descObj
    end
	EID.TabDescThisFrame = true
	EID.inModifierPreview = true
	local descEntry = EID:getDescriptionObj(5, 100, EID.TabPreviewID)
	EID.inModifierPreview = false
	descEntry.Entity = descObj.Entity
	EID.TabPreviewID = 0
	return descEntry
end

local function TabConditions(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 100 and EID:PlayersActionPressed(EID.Config["BagOfCraftingToggleKey"]) and not EID.inModifierPreview then
        local numPlayers = Game():GetNumPlayers()
        for i = 0, numPlayers - 1 do
            if Isaac.GetPlayer(i):HasCollectible(Astro.Collectible.SPINUP_DICE) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(Astro.Collectible.SPINUP_DICE)]) then
                return true
            end
        end
    end
	EID.TabPreviewID = 0
	return false
end

local function SpinupModifierCondition(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 100 then
        local numPlayers = Game():GetNumPlayers()
        for i = 0, numPlayers - 1 do
            local player = Isaac.GetPlayer(i)
            if player:HasCollectible(Astro.Collectible.SPINUP_DICE) or player:HasCollectible(Astro.Collectible.QUBIT_DICE) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(Astro.Collectible.SPINUP_DICE)]) then
                return true
            end
        end
    end
end

local function SpinupModifierCallback(descObj)
    local playerID, icon, hasCarBattery
    local numPlayers = Game():GetNumPlayers()

    -- items check
    for i = 0, numPlayers - 1 do
        if Isaac.GetPlayer(i):HasCollectible(Astro.Collectible.SPINUP_DICE) or Isaac.GetPlayer(i):HasCollectible(Astro.Collectible.QUBIT_DICE) or (EID.absorbedItems[tostring(i)] and EID.absorbedItems[tostring(i)][tostring(Astro.Collectible.SPINUP_DICE)]) then
            playerID = i
            icon = "#{{Collectible" .. Astro.Collectible.SPINUP_DICE .. "}} :"
            break
        end
    end
    if playerID then
        EID:appendToDescription(descObj, icon)
        local refID = descObj.ObjSubType
        if refID == 668 then EID:appendToDescription(descObj, "No Effect") return descObj end
        hasCarBattery = Isaac.GetPlayer(playerID):HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
        local firstID = 0
        for i = 1,EID.Config["SpindownDiceResults"] do
            local spinnedID = GetSpinupResult(refID)
            if hasCarBattery then
                refID = spinnedID
                spinnedID = GetSpinupResult(refID)
            end
            refID = spinnedID

            if refID < 4294960000 then
                if EID.itemConfig:GetCollectible(refID) == nil then EID:appendToDescription(descObj, "Loops back to {{Collectible1}}") break
                else
                    if i == 1 then firstID = refID end
                    EID:appendToDescription(descObj, "{{Collectible"..refID.."}}")
                    --if EID.itemUnlockStates[refID] == false then EID:appendToDescription(descObj, "?") end
                    if EID.Config["SpindownDiceDisplayID"] then EID:appendToDescription(descObj, "/".. refID) end
                    if EID.Config["SpindownDiceDisplayName"] then EID:appendToDescription(descObj, "/".. EID:getObjectName(5, 100, refID))
                        if i ~= EID.Config["SpindownDiceResults"] then EID:appendToDescription(descObj, "#{{Blank}}") end
                    end
                    if i ~= EID.Config["SpindownDiceResults"] then EID:appendToDescription(descObj, " ->") end
                end
            end
        end
        if hasCarBattery then EID:appendToDescription(descObj, " (Results with {{Collectible356}})") end
        if firstID ~= 0 and EID.TabPreviewID == 0 then
            EID.TabPreviewID = firstID
            if not EID.inModifierPreview then EID:appendToDescription(descObj, "#{{Blank}} " .. EID:getDescriptionEntry("FlipItemToggleInfo")) end
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

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local entities = Isaac:GetRoomEntities()
        --local itemPool = Game():GetItemPool()
        local nextid

        for i=1, #entities do
            if entities[i].Type == EntityType.ENTITY_PICKUP and
            entities[i].Variant == PickupVariant.PICKUP_COLLECTIBLE and
            ((entities[i].SubType ~= 0) and (entities[i].SubType ~= 668) and (entities[i].SubType ~= 2^32-1))
            then
                nextid = entities[i].SubType + 1

                --if it's Dad's Note or a stray empty ID 
                if nextid == 668 or Isaac.GetItemConfig():GetCollectible(nextid) == nil then
                    nextid = nextid + 1
                    --ckeck if you were at the very last item 
                    if (Isaac.GetItemConfig():GetCollectible(nextid) == nil and Isaac.GetItemConfig():GetCollectible(nextid+1) == nil) then					
                        nextid = 1
                    end

                end

                --Check if it's a hidden item
                while (Isaac.GetItemConfig():GetCollectible(nextid) ~= nil and Isaac.GetItemConfig():GetCollectible(nextid).Hidden == true) do

                    nextid = nextid + 1

                    if (Isaac.GetItemConfig():GetCollectible(nextid) == nil and Isaac.GetItemConfig():GetCollectible(nextid+1) == nil) then

                        nextid = 1

                    elseif (Isaac.GetItemConfig():GetCollectible(nextid) == nil and Isaac.GetItemConfig():GetCollectible(nextid+1) ~= nil) then
                        nextid = nextid + 1
                    end
                end

            entities[i]:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, nextid, true)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, entities[i].Position, entities[i].Velocity, playerWhoUsedItem)

            end
        end
        return true
    end,
    Astro.Collectible.SPINUP_DICE
)

StartDebug();
local spriteCache = {}


local function GetNextAvailableCollectibleSubType(entity, spinAmount)
  local subType = entity.SubType;
  local itemCfg = nil
  
  while itemCfg == nil do
  
		if subType < 1 then return nil end
		
		if (Isaac.GetItemConfig():GetCollectible( subType ) ~= nil) and (Isaac.GetItemConfig():GetCollectible( (subType + 1) ) == nil) then
			
			if (Isaac.GetItemConfig():GetCollectible( (subType + 2) ) == nil)  then
				if spinAmount == 1 then
					subType = 1
					return subType
				else
					subType = 2
					return subType
				end
			end
			
			subType = subType + 1
			
			
		end	
		
		
		subType = subType + 1
		  
		itemCfg = Isaac.GetItemConfig():GetCollectible( subType )
		  
		if itemCfg~= nil and itemCfg.Hidden == false then
			spinAmount = spinAmount - 1  
		end
		  
		if (itemCfg ~= nil and itemCfg.Hidden == true) or (spinAmount > 0) then
			itemCfg = nil
		end
		
		if subType == 668 then
			subType = 669
		end
		  
	end


  return subType
end

local function IsItem( entity )
    return entity ~= nil and entity:ToPickup() ~= nil and entity.Variant == 100
end

local function GetAvailableSkipAmount()
    local playerCount = Game():GetNumPlayers()
    local currentSkipAmount = 0
    
    for i = 0, playerCount - 1 do
        local p = Isaac.GetPlayer(i)
        local hasCarBattery = p:HasCollectible( CollectibleType.COLLECTIBLE_CAR_BATTERY )
        local spinAmount = 1
        
        if p ~= nil and ( p:GetActiveItem ( ActiveSlot.SLOT_PRIMARY ) == Astro.Collectible.SPINUP_DICE or p:GetActiveItem ( ActiveSlot.SLOT_POCKET ) == Astro.Collectible.SPINUP_DICE ) then
            if hasCarBattery then
                spinAmount = spinAmount + 1
            end
                
            currentSkipAmount = math.max( currentSkipAmount, spinAmount )
        end
    end
    
    return currentSkipAmount
end

local function RenderCollectible(entity, spinAmount)
    local nextCollectibleSubType = GetNextAvailableCollectibleSubType(entity, spinAmount)
    
    if nextCollectibleSubType == nil then return end
    
    local itemConfig = Isaac.GetItemConfig():GetCollectible( nextCollectibleSubType )
    
    if itemConfig ~= nil then
        descriptor = itemConfig.GfxFileName
        
        local itemSprite
        

        if spriteCache[ descriptor ] == nil then
            itemSprite = Sprite()
            itemSprite:Load("gfx/005.100_Collectible.anm2", true)
            itemSprite:ReplaceSpritesheet(1, itemConfig.GfxFileName )
            itemSprite:LoadGraphics()
            itemSprite.Color = Color(1,1,1,0.45)
            itemSprite:SetFrame("Idle", 8)
            itemSprite.Scale = Vector(0.4, 0.4)
            
            spriteCache[descriptor] = itemSprite
        else
            itemSprite = spriteCache[descriptor]
        end
        

        local adjustedPosition = Vector(0,0)
        
        if entity:ToPickup():IsShopItem() then 
            adjustedPosition = entity.Position - Vector(-22, 20)
        else
            adjustedPosition = entity.Position - Vector(-22, 38)
        end
        
        itemSprite:Render( Isaac.WorldToScreen( adjustedPosition ), Vector( 0,0 ), Vector( 0,0 ))
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        local spinAmount = GetAvailableSkipAmount()
    
        if spinAmount == 0 then return nil end
        
    
        local curseName = Game():GetLevel():GetCurseName()
        
    
        if curseName ~= nil and curseName == "Curse of the Blind!" then return nil end
        
        local player = Isaac.GetPlayer( 0 )
        local pickups = Isaac.FindInRadius( player.Position, 600, EntityPartition.PICKUP )
        
        for i, entity in ipairs( pickups ) do
            if IsItem( entity ) then
                RenderCollectible( entity,spinAmount )
            end
        end
    end
)

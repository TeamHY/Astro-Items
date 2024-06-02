local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Data = {}

-- Load Data
AstroItems:AddPriorityCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    CallbackPriority.IMPORTANT,
    ---@param isContinued boolean
    function(_, isContinued)
        if AstroItems:HasData() then
            local raw = AstroItems:LoadData()
            local data = Json.decode(raw)

            AstroItems.Data = data or {}

            hiddenItemManager:LoadData(AstroItems.Data.HiddenItemData)
        end

        if not isContinued then
            AstroItems.Data.PersistentPlayerData = {}
            AstroItems.Data.PersistentPickupData = {}
        end
    end
)

-- Save Data
AstroItems:AddPriorityCallback(
    ModCallbacks.MC_PRE_GAME_EXIT,
    CallbackPriority.LATE,
    ---@param shouldSave boolean
    function(_, shouldSave)
        AstroItems.Data.HiddenItemData = hiddenItemManager:GetSaveData()
        AstroItems:SaveData(Json.encode(AstroItems.Data))
    end
)

--- Credit to Xalum(Retribution)
---@param player EntityPlayer
function AstroItems:GetPersistentPlayerData(player)
	if AstroItems.Data and AstroItems.Data.PersistentPlayerData then
		local seedReference = CollectibleType.COLLECTIBLE_SKELETON_KEY
		local playerType = player:GetPlayerType()

		if playerType == PlayerType.PLAYER_LAZARUS2_B then
			seedReference = CollectibleType.COLLECTIBLE_DOLLAR
		elseif playerType ~= PlayerType.PLAYER_ESAU then
			player = player:GetMainTwin()
		end

		local tableIndex = tostring(player:GetCollectibleRNG(seedReference):GetSeed())

		AstroItems.Data.PersistentPlayerData[tableIndex] = AstroItems.Data.PersistentPlayerData[tableIndex] or {}
		return AstroItems.Data.PersistentPlayerData[tableIndex]
	end
end

--- Credit to Xalum(Retribution)
---@param pickup EntityPickup
function AstroItems:GetPersistentPickupData(pickup)
	if AstroItems.Data and AstroItems.Data.PersistentPickupData then
		local tableIndex = tostring(pickup.InitSeed)
		AstroItems.Data.PersistentPickupData[tableIndex] = AstroItems.Data.PersistentPickupData[tableIndex] or {}
		return AstroItems.Data.PersistentPickupData[tableIndex]
	end
end

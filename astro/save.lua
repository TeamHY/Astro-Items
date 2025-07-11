local hiddenItemManager = require("astro.lib.hidden_item_manager")
local saveManager = require("astro.lib.save_manager")

Astro.Data = {}

-- Load Data
Astro:AddCallback(
    saveManager.SaveCallbacks.POST_DATA_LOAD,
    function(_, saveData, isLuamod)
        Astro.Data = saveData.file.other.AstroData or {}
        hiddenItemManager:LoadData(Astro.Data.HiddenItemData)
    end
)

-- Save Data
Astro:AddCallback(
    saveManager.SaveCallbacks.PRE_DATA_SAVE,
    function(_, saveData)
        Astro.Data.HiddenItemData = hiddenItemManager:GetSaveData()
        saveData.file.other.AstroData = Astro.Data
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    CallbackPriority.IMPORTANT,
    function(_, isContinued)
        if not isContinued then
            Astro.Data.PersistentPlayerData = {}
            Astro.Data.PersistentPickupData = {}
        end
    end
)

--- Credit to Xalum(Retribution)
---@param player EntityPlayer
function Astro:GetPersistentPlayerData(player)
	if Astro.Data and Astro.Data.PersistentPlayerData then
		local seedReference = CollectibleType.COLLECTIBLE_SKELETON_KEY
		local playerType = player:GetPlayerType()

		if playerType == PlayerType.PLAYER_LAZARUS2_B then
			seedReference = CollectibleType.COLLECTIBLE_DOLLAR
		elseif playerType ~= PlayerType.PLAYER_ESAU then
			player = player:GetMainTwin()
		end

		local tableIndex = tostring(player:GetCollectibleRNG(seedReference):GetSeed())

		Astro.Data.PersistentPlayerData[tableIndex] = Astro.Data.PersistentPlayerData[tableIndex] or {}
		return Astro.Data.PersistentPlayerData[tableIndex]
	end
end

--- Credit to Xalum(Retribution)
---@param pickup EntityPickup
function Astro:GetPersistentPickupData(pickup)
	if Astro.Data and Astro.Data.PersistentPickupData then
		local tableIndex = tostring(pickup.InitSeed)
		Astro.Data.PersistentPickupData[tableIndex] = Astro.Data.PersistentPickupData[tableIndex] or {}
		return Astro.Data.PersistentPickupData[tableIndex]
	end
end

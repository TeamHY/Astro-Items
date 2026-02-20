local hiddenItemManager = require("astro.lib.hidden_item_manager")
local saveManager = require("astro.lib.save_manager")
local isc = require("astro.lib.isaacscript-common")

local mod = RegisterMod("AstroItems", 1)

hiddenItemManager:Init(mod)

saveManager.Init(mod)

Astro = isc:upgradeMod(mod, { isc.ISCFeature.PLAYER_INVENTORY, isc.ISCFeature.ROOM_HISTORY })
Astro.HiddenItemManager = hiddenItemManager
Astro.SaveManager = saveManager
Astro.DDSMyMod = mod

local function GetCurrentModPath()
	if debug then
		return string.sub(debug.getinfo(GetCurrentModPath).source, 2) .. "/../"
	end
	--use some very hacky trickery to get the path to this mod
	local _, err = pcall(require, "")
	local _, basePathStart = string.find(err, "no file '", 1)
	local _, modPathStart = string.find(err, "no file '", basePathStart)
	local modPathEnd, _ = string.find(err, ".lua'", modPathStart)
	local modPath = string.sub(err, modPathStart + 1, modPathEnd - 1)
	modPath = string.gsub(modPath, "\\", "/")
	modPath = string.gsub(modPath, "//", "/")
	modPath = string.gsub(modPath, ":/", ":\\")

	return modPath
end
Astro.ModPath = GetCurrentModPath()
local modPath = Astro.ModPath

require "astro.constants"
require "astro.save"
require "astro.callbacks"
require "astro.eid"
require "astro.utils.init"
require "astro.upgrade-action"
require "astro.mcm"
require "astro.mega-ui"
require "astro.entities.init"
require "astro.collectibles.init"
require "astro.trinkets.init"
require "astro.player"
require "astro.ban"
require "astro.room"
require "astro.curse"
require "astro.large-sprite"
require "astro.birthright"
require "astro.translate"
require "astro.transformations.init"

local font = Font()
font:Load(modPath .. "resources/font/eid_korean_soyanon.fnt")

local background = Sprite()
background:Load("gfx/ui/astro_warning.anm2")
background:LoadGraphics()
background:Play("Idle", true)

local warnings = {}

-- if not REPENTANCE_PLUS then
-- 	table.insert(warnings, "Repentance+ DLC가 필요합니다.")
-- end

-- if not HY_POCKETS then
-- 	table.insert(warnings, "추가 소모성 모드가 필요합니다.")
-- end

-- if not GoldenItems then
-- 	table.insert(warnings, "황금 아이템 모드가 필요합니다.")
-- end

Astro:AddCallback(
	ModCallbacks.MC_POST_RENDER,
	function(_)
		if #warnings > 0 then
			local centerX = Isaac.GetScreenWidth() / 2
			local centerY = Isaac.GetScreenHeight() / 2

			background:Render(Vector(centerX, centerY), Vector(0, 0), Vector(0, 0))

			for i, warning in ipairs(warnings) do
				font:DrawStringUTF8(warning, centerX - 104, centerY - 4 - math.floor(#warnings * 16 / 2) + (i - 1) * 16, KColor(1, 1, 1, 1), 200, true)
			end
		end
	end
)

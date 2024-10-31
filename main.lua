local hiddenItemManager = require("astro.lib.hidden_item_manager")
local isc = require("astro.lib.isaacscript-common")

local mod = RegisterMod("AstroItems", 1)

hiddenItemManager:Init(mod)

Astro = isc:upgradeMod(mod, { isc.ISCFeature.PLAYER_INVENTORY, isc.ISCFeature.ROOM_HISTORY })
Astro.HiddenItemManager = hiddenItemManager

Json = require "json"

require "astro.constants"
require "astro.save"
require "astro.callbacks"
require "astro.eid"
require "astro.utils.init"
require "astro.entities.init"
require "astro.collectibles.init"
require "astro.trinkets.init"
require "astro.player"
require "astro.room"
require "astro.curse"

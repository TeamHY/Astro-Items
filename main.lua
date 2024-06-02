local hiddenItemManager = require("astro-items.lib.hidden_item_manager")
local isc = require("astro-items.lib.isaacscript-common")

local mod = RegisterMod("AstroItems", 1)

hiddenItemManager:Init(mod)

AstroItems = isc:upgradeMod(mod, { isc.ISCFeature.PLAYER_INVENTORY, isc.ISCFeature.ROOM_HISTORY })

Json = require "json"

require "astro-items.constants"
require "astro-items.save"
require "astro-items.eid"
require "astro-items.utill"
require "astro-items.collectibles.init"
require "astro-items.trinkets.init"
require "astro-items.cards.init"
require "astro-items.monsters.init"
require "astro-items.player"
require "astro-items.room"

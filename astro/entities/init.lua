---@class Astro.Entity
---@field Type integer
---@field Variant integer
---@field SubType integer

---@type {[string]: Astro.Entity}
Astro.Entity = {}

require "astro.entities.astro-crane-game"
require "astro.entities.soul"
require "astro.entities.star"
require "astro.entities.dust"
require "astro.entities.lava-beggar"
require "astro.entities.planetarium-beggar"
require "astro.entities.glitched-machine"

Astro:AddCallback(
	ModCallbacks.MC_POST_EFFECT_UPDATE,
	---@param effect EntityEffect
	function(_, effect)
		local data = effect:GetData()

		if data.Astro then
			if data.Astro.KillFrame and data.Astro.KillFrame <= Game():GetFrameCount() then
				effect:Die()
			end
		end
	end
)

require "astro.entities.astro-crane-game"
require "astro.entities.soul"
require "astro.entities.star"
require "astro.entities.dust"
require "astro.entities.lava-beggar"

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

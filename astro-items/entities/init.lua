require "astro-items.entities.soul"
require "astro-items.entities.star"
require "astro-items.entities.dust"

AstroItems:AddCallback(
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

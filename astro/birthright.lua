require "astro.birthright.1-leah"
--require "astro.birthright.2-rachel"
--require "astro.birthright.3-diabellstar"
--require "astro.birthright.4-diabellze"
--require "astro.birthright.5-waterenchantress"
--require "astro.birthright.6-illegalknight"
--require "astro.birthright.7-davidmartinez"
--require "astro.birthright.8-lucy"
--require "astro.birthright.9-stellar"
--require "astro.birthright.10-nayuta"
--require "astro.birthright.11-ainzooalgown"
--require "astro.birthright.12-pandorasactor"

-- from 'unique birthright sprite'
function Astro:BirthrightUpdate(entity)
	local player = Isaac.GetPlayer(0)
	local playerType = player:GetPlayerType()
    local level = Game():GetLevel()
	
	if entity.Type == 5 and entity.Variant == 100 and entity.SubType == 619 and math.floor(level:GetCurses() / LevelCurse.CURSE_OF_BLIND) % 2 == 0 then
		local sprite = entity:GetSprite()
		
		if playerType == Astro.Players.DAVID_MARTINEZ then
			sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/birthright/david.png")
		elseif playerType == Astro.Players.DAVID_MARTINEZ_B then
			sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/birthright/lucy.png")
		end
		sprite:LoadGraphics()
    end
end

Astro:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Astro.BirthrightUpdate)
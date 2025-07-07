local isc = require("astro.lib.isaacscript-common")

Astro.EID = {}

Astro.EID.QualityIcon = Sprite()
Astro.EID.QualityIcon:Load("gfx/ui/eid/quality.anm2")
Astro.EID.QualityIcon:LoadGraphics()

EID:addIcon("Quality5", "Quality5", 0, 10, 10, 0, 0, Astro.EID.QualityIcon)
EID:addIcon("Quality6", "Quality6", 0, 10, 10, 0, 0, Astro.EID.QualityIcon)

---@param id CollectibleType
---@param name string
---@param description string
---@param eidDescription string
function Astro:AddEIDCollectible(id, name, description, eidDescription)
    if EID then
        EID:addCollectible(id, eidDescription, name)
    end

    Astro.EID[id] = {
        name = name,
        description = description
    }
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.PRE_ITEM_PICKUP,
    ---@param player EntityPlayer
    ---@param pickingUpItem { itemType: ItemType, subType: CollectibleType | TrinketType }
    function(_, player, pickingUpItem)
        if Options.Language == "kr" or REPKOR then
            if pickingUpItem.itemType ~= ItemType.ITEM_TRINKET then
                local item = Astro.EID[pickingUpItem.subType]

                if item then
                    Game():GetHUD():ShowItemText(item.name or '', item.description or '')
                end
            end
        end
    end
)

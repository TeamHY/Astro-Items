local isc = require("astro-items.lib.isaacscript-common")

AstroItems.EID = {}

---@param id CollectibleType
---@param name string
---@param description string
---@param eidDescription string
function AstroItems:AddEIDCollectible(id, name, description, eidDescription)
    print(id)

    if EID then
        EID:addCollectible(id, eidDescription, name)
    end

    AstroItems.EID[id] = {
        name = name,
        description = description
    }
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.PRE_ITEM_PICKUP,
    ---@param player EntityPlayer
    ---@param pickingUpItem { itemType: ItemType, subType: CollectibleType | TrinketType }
    function(_, player, pickingUpItem)
        if Options.Language == "kr" then
            if pickingUpItem.itemType ~= ItemType.ITEM_TRINKET then
                local item = AstroItems.EID[pickingUpItem.subType]

                if item then
                    Game():GetHUD():ShowItemText(item.name or '', item.description or '')
                end
            end
        end
    end
)

local isc = require("astro.lib.isaacscript-common")

Astro.EID = {}
Astro.EID.Trinket = {}

Astro.EID.QualityIcon = Sprite()
Astro.EID.QualityIcon:Load("gfx/ui/eid/quality.anm2")
Astro.EID.QualityIcon:LoadGraphics()

EID:addIcon("Quality5", "Quality5", 0, 10, 10, 0, 0, Astro.EID.QualityIcon)
EID:addIcon("Quality6", "Quality6", 0, 10, 10, 0, 0, Astro.EID.QualityIcon)

---@param id CollectibleType
---@param name string
---@param description string
---@param eidDescription string
---@param copied string?
function Astro:AddEIDCollectible(id, name, description, eidDescription, copied)
    if EID then
        EID:addCollectible(id, eidDescription, name, "ko_kr")

        if copied and Astro.Trinket then
            EID:addCondition(
                "5.100." .. tostring(id),
                {
                    "5.100." .. tostring(id),
                    "5.350." .. tostring(Astro.Trinket.BLACK_MIRROR),
                    "5.100.347", "5.100.485"
                },
                copied,
                nil, "ko_kr", nil
            )
        end
    end

    Astro.EID[id] = {
        name = name,
        description = description
    }
end

---@param id TrinketType
---@param name string
---@param description string
---@param eidDescription string
---@param golden string
function Astro:AddEIDTrinket(id, name, description, eidDescription, golden)
    if EID then
        EID:addTrinket(id, eidDescription, name, "ko_kr")

        if golden then
            EID:addGoldenTrinketMetadata(id, golden, nil, nil, "ko_kr")
        end
    end

    Astro.EID.Trinket[id] = {
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
                if item and not REPENTOGON then
                    Game():GetHUD():ShowItemText(item.name or '', item.description or '')
                end
            else
                local trinket = Astro.EID.Trinket[pickingUpItem.subType]
                if trinket and not REPENTOGON then
                    Game():GetHUD():ShowItemText(trinket.name or '', trinket.description or '')
                end
            end
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            EID:setModIndicatorName("AstroItems")
            ----
            local player_icons = Sprite()
            player_icons:Load("gfx/ui/eid_astrocharacter_icons.anm2", true)

            EID:addIcon("Leah", "Players", 0, 16, 16, 0, 3, player_icons)
            EID:addIcon("Rachel", "Players", 1, 16, 16, 0, 3, player_icons)
            EID:addIcon("Diabellstar", "Players", 2, 16, 16, 0, 3, player_icons)
            EID:addIcon("Diabellze", "Players", 3, 16, 16, 0, 3, player_icons)
            EID:addIcon("WaterEnchantress", "Players", 4, 16, 16, 0, 3, player_icons)
            EID:addIcon("IllegalKnight", "Players", 5, 16, 16, 0, 3, player_icons)
            EID:addIcon("DavidMartinez", "Players", 6, 16, 16, 0, 3, player_icons)
            EID:addIcon("Lucy", "Players", 7, 16, 16, 0, 3, player_icons)
            EID:addIcon("Stellar", "Players", 8, 16, 16, 0, 3, player_icons)
            EID:addIcon("Nayuta", "Players", 9, 16, 16, 0, 3, player_icons)
            EID:addIcon("AinzOoalGown", "Players", 10, 16, 16, 0, 3, player_icons)
            EID:addIcon("PandorasActor", "Players", 11, 16, 16, 0, 3, player_icons)

            EID.InlineIcons["Player" .. Astro.Players.LEAH] = EID.InlineIcons["Leah"]
            EID.InlineIcons["Player" .. Astro.Players.LEAH_B] = EID.InlineIcons["Rachel"]
            EID.InlineIcons["Player" .. Astro.Players.DIABELLSTAR] = EID.InlineIcons["Diabellstar"]
            EID.InlineIcons["Player" .. Astro.Players.DIABELLSTAR_B] = EID.InlineIcons["Diabellze"]
            EID.InlineIcons["Player" .. Astro.Players.WATER_ENCHANTRESS] = EID.InlineIcons["WaterEnchantress"]
            EID.InlineIcons["Player" .. Astro.Players.WATER_ENCHANTRESS_B] = EID.InlineIcons["IllegalKnight"]
            EID.InlineIcons["Player" .. Astro.Players.DAVID_MARTINEZ] = EID.InlineIcons["DavidMartinez"]
            EID.InlineIcons["Player" .. Astro.Players.DAVID_MARTINEZ_B] = EID.InlineIcons["Lucy"]
            EID.InlineIcons["Player" .. Astro.Players.STELLAR] = EID.InlineIcons["Stellar"]
            EID.InlineIcons["Player" .. Astro.Players.STELLAR_B] = EID.InlineIcons["Nayuta"]
            EID.InlineIcons["Player" .. Astro.Players.AINZ_OOAL_GOWN] = EID.InlineIcons["AinzOoalGown"]
            EID.InlineIcons["Player" .. Astro.Players.AINZ_OOAL_GOWN_B] = EID.InlineIcons["PandorasActor"]
        end
    end
)

if REPENTOGON then
	Astro:AddPriorityCallback(
        Astro.Callbacks.MOD_INIT,
        CallbackPriority.LATE,
        function()
            if not (REPKOR or Options.Language == "kr") then goto continue end
            local conf = Isaac.GetItemConfig()

            if Astro.EID then
                for key, entry in pairs(Astro.EID) do
                    local id = tonumber(key)
                    if id and id ~= -1 then
                        local cfg = conf:GetCollectible(id)
                        cfg.Name = entry.name
                        cfg.Description = entry.description
                    end
                end
            end

            if Astro.EID.Trinket then
                for key, entry in pairs(Astro.EID.Trinket) do
                    local id = tonumber(key)
                    if id and id ~= -1 then
                        local cfg = conf:GetTrinket(id)
                        cfg.Name = entry.name
                        cfg.Description = entry.description
                    end
                end
            end

            ::continue::
        end
    )
end
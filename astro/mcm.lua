local defaultSetting = {
    ["ShowQ5Hint"] = 0,
    ["TaurusExMode"] = 0,
    ["TaurusExKeyBind"] = Keyboard.KEY_V,
    ["AltLuckyPennyColor"] = 1,
}

----

if ModConfigMenu then
    ModConfigMenu.AddSetting("Astrobirth", nil,
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        Attribute = "ShowQ5Hint",
        Minimum = 0,
        Maximum = 1,
        ModifyBy = 1,
        CurrentSetting = function()
            return Astro.Data["ShowQ5Hint"]
        end,
        Display = function()
            if Astro.Data["ShowQ5Hint"] == 1 then
                return "Show Craft Hint: On"
            else
                return "Show Craft Hint: Off"
            end
        end,
        OnChange = function(newOption)
            Astro.Data["ShowQ5Hint"] = newOption;
        end,
        Info = "The crafting recipe for hidden items is displayed in the EID."
    });
    ModConfigMenu.AddSetting("Astrobirth", nil,
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        Attribute = "TaurusExMode",
        Minimum = 0,
        Maximum = 1,
        ModifyBy = 1,
        CurrentSetting = function()
            return Astro.Data["TaurusExMode"]
        end,
        Display = function()
            if Astro.Data["TaurusExMode"] == 1 then
                return "Taurus EX Mode: Double tap"
            else
                return "Taurus EX Mode: Single tap"
            end
        end,
        OnChange = function(newOption)
            Astro.Data["TaurusExMode"] = newOption;
        end,
        Info = "Choose whether Taurus EX’s dash is triggered by double-tapping a movement key (like Mars) or by pressing a separate assigned key once."
    });
    ModConfigMenu.AddSetting("Astrobirth", nil,
    {
        Type = ModConfigMenu.OptionType.KEYBIND_KEYBOARD,
        CurrentSetting = function()
            return Astro.Data["TaurusExKeyBind"]
        end,
        Display = function()
            local key = "None"
            if (InputHelper.KeyboardToString[Astro.Data["TaurusExKeyBind"]]) then
                key = InputHelper.KeyboardToString[Astro.Data["TaurusExKeyBind"]]
            end
            return "Toggle Key: " .. key
        end,
        OnChange = function(currentNum)
            Astro.Data["TaurusExKeyBind"] = currentNum or -1
        end,
        PopupGfx = ModConfigMenu.PopupGfx.WIDE_SMALL,
        PopupWidth = 280,
        Popup = function()
            local currentValue = Astro.Data["TaurusExKeyBind"]
            local keepSettingString = ""
            if currentValue > -1 then
                local currentSettingString = InputHelper.KeyboardToString[currentValue]
                keepSettingString = 'Current key: "' .. currentSettingString .. 
                    '".$newlinePress this key again to keep it.$newline$newline'
            end
            return "Press any key to set as toggle key.$newline$newline" ..
                keepSettingString .. "Press ESCAPE to clear this setting."
        end,
        Info = "(Functions when the Taurus EX Mode option is set to Single tap) Configure the key to trigger the Taurus EX dash."
    });
    ModConfigMenu.AddSetting("Astrobirth", nil,
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        Attribute = "AltLuckyPennyColor",
        Minimum = 0,
        Maximum = 1,
        ModifyBy = 1,
        CurrentSetting = function()
            return Astro.Data["AltLuckyPennyColor"]
        end,
        Display = function()
            if Astro.Data["AltLuckyPennyColor"] == 1 then
                return "Alternative Double Lucky Penny Color: On"
            else
                return "Alternative Double Lucky Penny Color: Off"
            end
        end,
        OnChange = function(newOption)
            Astro.Data["AltLuckyPennyColor"] = newOption;
        end,
        Info = "Change the color of the Double Lucky Penny."
    });
end

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        Astro.Data["ShowQ5Hint"] = Astro.Data["ShowQ5Hint"] or defaultSetting["ShowQ5Hint"]
        Astro.Data["TaurusExMode"] = Astro.Data["TaurusExMode"] or defaultSetting["TaurusExMode"]
        Astro.Data["TaurusExKeyBind"] = Astro.Data["TaurusExKeyBind"] or defaultSetting["TaurusExKeyBind"]
        Astro.Data["AltLuckyPennyColor"] = Astro.Data["AltLuckyPennyColor"] or defaultSetting["AltLuckyPennyColor"]
    end
)
Astro.Data["ShowQ5Hint"] = 1
Astro.Data["TaurusExMode"] = 0
Astro.Data["TaurusExKeyBind"] = Keyboard.KEY_V

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
                return "Show Q5 Hint: On"
            else
                return "Show Q5 Hint: Off"
            end
        end,
        OnChange = function(newOption)
            Astro.Data["ShowQ5Hint"] = newOption;
        end,
        Info = "The crafting recipe for a Q5 item is displayed in the EID."
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
end

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        Astro.Data["ShowQ5Hint"] = Astro.Data["ShowQ5Hint"] or 1
        Astro.Data["TaurusExMode"] = Astro.Data["TaurusExMode"] or 1
        Astro.Data["TaurusExKeyBind"] = Astro.Data["TaurusExKeyBind"] or Keyboard.KEY_V
    end
)
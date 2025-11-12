--
-- Generic and very straightforward data storage system used in the MenuProvider functions below
-- Use your own mod's functions for this if it has them! If not, however, feel free to copy this and
-- change the mod name.
--
local myMod = Astro
myMod.menusavedata = nil

local json = require("json")
function myMod.GetSaveData()
    if not myMod.menusavedata then
        if Isaac.HasModData(myMod) then
            myMod.menusavedata = json.decode(Isaac.LoadModData(myMod))
        else
            myMod.menusavedata = {}
        end
    end

    return myMod.menusavedata
end

function myMod.StoreSaveData()
    Isaac.SaveModData(myMod, json.encode(myMod.menusavedata))
end

--
-- End of generic data storage manager
--

--
-- MenuProvider
--

-- Change this variable to match your mod. The standard is "Dead Sea Scrolls (Mod Name)"
local DSSModName = "astrobirth"

-- Every MenuProvider function below must have its own implementation in your mod, in order to
-- handle menu save data.
local MenuProvider = {}

function MenuProvider.SaveSaveData()
    myMod.StoreSaveData()
end

function MenuProvider.GetPaletteSetting()
    return myMod.GetSaveData().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    myMod.GetSaveData().MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    if not REPENTANCE then
        return myMod.GetSaveData().HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
        myMod.GetSaveData().HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    return myMod.GetSaveData().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    myMod.GetSaveData().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return myMod.GetSaveData().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    myMod.GetSaveData().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return myMod.GetSaveData().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    myMod.GetSaveData().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return myMod.GetSaveData().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    myMod.GetSaveData().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return myMod.GetSaveData().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    myMod.GetSaveData().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return myMod.GetSaveData().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    myMod.GetSaveData().MenusPoppedUp = var
end

local dssmenucore = require "astro.lib.dssmenucore"
do
    local saved = myMod.GetSaveData() or {}
    Astro.EID.ShowHint = (saved.EIDQuality5Hint == 2)
    Astro.EID.HintAdded = false
end

-- This function returns a table that some useful functions and defaults are stored on.
local dssmod = dssmenucore.init(DSSModName, MenuProvider)


-- Adding a Menu

-- Creating a menu like any other DSS menu is a simple process. You need a "Directory", which
-- defines all of the pages ("items") that can be accessed on your menu, and a "DirectoryKey", which
-- defines the state of the menu.
local exampledirectory = {
    -- The keys in this table are used to determine button destinations.
    main = {
        -- "title" is the big line of text that shows up at the top of the page!
        title = 'astrobirth',
        -- "buttons" is a list of objects that will be displayed on this page. The meat of the menu!
        buttons = {
            -- The simplest button has just a "str" tag, which just displays a line of text.

            -- The "action" tag can do one of three pre-defined actions:
            -- 1) "resume" closes the menu, like the resume game button on the pause menu. Generally
            --    a good idea to have a button for this on your main page!
            -- 2) "back" backs out to the previous menu item, as if you had sent the menu back
            --    input.
            -- 3) "openmenu" opens a different dss menu, using the "menu" tag of the button as the
            --    name.
            { str = 'resume game', action = 'resume' },

            -- The "dest" option, if specified, means that pressing the button will send you to that
            -- page of your menu.
            -- If using the "openmenu" action, "dest" will pick which item of that menu you are sent
            -- to.
            { str = 'settings',    dest = 'settings' },

            -- A few default buttons are provided in the table returned from the `init` function.
            -- They are buttons that handle generic menu features, like changelogs, palette, and the
            -- menu opening keybind. They will only be visible in your menu if your menu is the only
            -- mod menu active. Otherwise, they will show up in the outermost Dead Sea Scrolls menu
            -- that lets you pick which mod menu to open. This one leads to the changelogs menu,
            -- which contains changelogs defined by all mods.
            dssmod.changelogsButton,

            -- Text font size can be modified with the "fsize" tag. There are three font sizes, 1,
            -- 2, and 3, with 1 being the smallest and 3 being the largest.
            -- { str = '', fsize = 1 }
        },
        -- A tooltip can be set either on an item or a button, and will display in the corner of the
        -- menu while a button is selected or the item is visible with no tooltip selected from a
        -- button. The object returned from the `init` function contains a default tooltip that
        -- describes how to open the menu, at "menuOpenToolTip". It's generally a good idea to use
        -- that one as a default!
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = 'settings',
        buttons = {
            -- These buttons are all generic menu handling buttons, provided in the table returned
            -- from the `init` function. They will only show up if your menu is the only mod menu
            -- active. You should generally include them somewhere in your menu, so that players can
            -- change the palette or menu keybind even if your mod is the only menu mod active. You
            -- can position them however you like, though!
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,

            {
                str = 'eid quality 5 hint',
                choices = { 'off', 'on' },
                setting = 1,
                variable = 'EIDQuality5Hint',
                load = function()
                    return myMod.GetSaveData().EIDQuality5Hint or 1
                end,
                store = function(var)
                    myMod.GetSaveData().EIDQuality5Hint = var
                    Astro.EID.ShowHint = (var == 2)
                end,
                tooltip = { strset = { 'show hints', 'for what', 'items can be', 'transformed', 'into', 'quality 5s' } }
            },
        }
    }
}

local exampledirectorykey = {
    -- This is the initial item of the menu, generally you want to set it to your main item
    Item = exampledirectory.main,
    -- The main item of the menu is the item that gets opened first when opening your mod's menu.
    Main = 'main',
    -- These are default state variables for the menu; they're important to have in here, but you
    -- don't need to change them at all.
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("astrobirth", {
    -- The Run, Close, and Open functions define the core loop of your menu. Once your menu is
    -- opened, all the work is shifted off to your mod running these functions, so each mod can have
    -- its own independently functioning menu. The `init` function returns a table with defaults
    -- defined for each function, as "runMenu", "openMenu", and "closeMenu". Using these defaults
    -- will get you the same menu you see in Bertran and most other mods that use DSS. But, if you
    -- did want a completely custom menu, this would be the way to do it!

    -- This function runs every render frame while your menu is open, it handles everything!
    -- Drawing, inputs, etc.
    Run = dssmod.runMenu,
    -- This function runs when the menu is opened, and generally initializes the menu.
    Open = dssmod.openMenu,
    -- This function runs when the menu is closed, and generally handles storing of save data /
    -- general shut down.
    Close = dssmod.closeMenu,
    -- If UseSubMenu is set to true, when other mods with UseSubMenu set to false / nil are enabled,
    -- your menu will be hidden behind an "Other Mods" button.
    -- A good idea to use to help keep menus clean if you don't expect players to use your menu very
    -- often!
    UseSubMenu = false,
    Directory = exampledirectory,
    DirectoryKey = exampledirectorykey
})

-- There are a lot more features that DSS supports not covered here, like sprite insertion and
-- scroller menus, that you'll have to look at other mods for reference to use. But, this should be
-- everything you need to create a simple menu for configuration or other simple use cases!

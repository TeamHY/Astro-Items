Astro.VarDataText = {}
Astro.VarDataText.Font = Font()
Astro.VarDataText.Font:Load(Astro.ModPath .. "resources/font/astro_vardatanumber.fnt")

---@param player EntityPlayer
---@param slot ActiveSlot
---@param string string
---@param customOffset Vector?
function Astro.VarDataText:RenderActiceVarDataText(player, slot, string, customOffset)
    local game = Game()
    local hud = game:GetHUD()
    if not hud:IsVisible() then return end

    customOffset = customOffset or Vector.Zero
    local pType = player:GetPlayerType()
    if pType ~= (PlayerType.PLAYER_JACOB or PlayerType.PLAYER_ESAU) and game:GetNumPlayers() < 2 then
        local screenW = Isaac.GetScreenWidth()
        local screenH = Isaac.GetScreenHeight()
        local shakeOffset = game.ScreenShakeOffset
        local font = Astro.VarDataText.Font

        if slot == ActiveSlot.SLOT_PRIMARY then
            local pos0 = Vector(4, 8) + customOffset
            local hudOffset0 = (Options.HUDOffset * Vector(20, 12))
            local finalPos0 = pos0 + hudOffset0 + shakeOffset
            
            font:DrawStringUTF8(string, finalPos0.X, finalPos0.Y, KColor(1, 1, 1, 1), 0, true)
        end

        if slot == ActiveSlot.SLOT_POCKET then
            local pos1 = Vector(screenW - 36, screenH - 28) + customOffset
            local hudOffset1 = (Options.HUDOffset * Vector(16, 6))
            local finalPos1 = pos1 - hudOffset1 + shakeOffset

            font:DrawStringUTF8(string, finalPos1.X, finalPos1.Y, KColor(1, 1, 1, 1), 0, true)
        end
    else
        local followPos = Astro:ToScreen(player.Position)
        font:DrawStringUTF8(string, followPos.X - 10, followPos.Y - 38, KColor(1, 1, 1, 1), 0, true)
    end
end
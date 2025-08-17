-- 사왈이 제작

local function utf8_sub(str, start_char, num_chars)
    local start_idx = utf8.offset(str, start_char)
    local end_idx = utf8.offset(str, start_char + num_chars) and utf8.offset(str, start_char + num_chars) - 1 or #str
    return string.sub(str, start_idx, end_idx)
end

local function trimString(text, max_len)    -- 번역이 너무 길면 화면 더러움
    if utf8.len(text) > max_len then
        local trimmed = utf8_sub(text, 1, max_len)
        trimmed = trimmed:gsub("%s+$", "")
        return trimmed .. "..."
    else
        return text
    end
end


local PocketItemStrings = {}

local function BuildPocketItemStrings()
    PocketItemStrings = {}

    local ic = Isaac.GetItemConfig()
    local numPlayers = Game():GetNumPlayers()

    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)
        if not player or not player:Exists() or not player:ToPlayer() then
            goto skip
        end

        local TrslName = nil
        local IsActiveItem = false
        local pocketItem = player:GetActiveItem(ActiveSlot.SLOT_POCKET)

        if pocketItem and pocketItem ~= 0 then
            local item = Astro.EID[pocketItem]
            if item and item.name and
               item.name ~= ic:GetCollectible(pocketItem).Name then    -- 액티브의 원본 이름이 다를 때만 작동
                TrslName = item.name

                if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) and item.description then
                    TrslName = trimString(item.description, 17)
                end

                IsActiveItem = true
            end
        end

        local id = #PocketItemStrings + 1
        PocketItemStrings[id] = {
            Name = TrslName or "",
            IsActiveItem = IsActiveItem,
            PType = player:GetPlayerType(),
            CtrlIdx = player.ControllerIndex
        }

        ::skip::
    end
end

Astro:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, cont)
    if not cont then
        PocketItemStrings = {}
    end 
end)

local font = Font()
font:Load(Astro.ModPath .. "resources/font/for translate/luaminioutlined.fnt")

local function RenderPocketItemName()
    if not Game():GetHUD():IsVisible() then return end
    if Game():GetNumPlayers() > 1 then return end    -- 멀티 유기

    local shakeOffset = Game().ScreenShakeOffset
    local fontSize, sizeOffset = 1, -2

    for i, k in pairs(PocketItemStrings) do
        if not k or not k.Name or k.Name == "" then
            goto skip
        end

        local id = i - 1
        local str = k.Name
        local alpha = 0.5
        local pType = k.PType
        local activeOffset = 0
        if k.IsActiveItem then
            activeOffset = -4
        end

        if (pType == PlayerType.PLAYER_JACOB or pType == PlayerType.PLAYER_ESAU) then
            goto skip    -- 병머 유기
        end

        if id == 0 then
            local Corner = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
            local Offset = -Vector(Options.HUDOffset * 16 + 30, Options.HUDOffset * 6 + 22)
            local Pos = Corner + Offset + shakeOffset
            font:DrawStringScaledUTF8(str, Pos.X + 1 + activeOffset, Pos.Y + 13 + sizeOffset, fontSize, fontSize, KColor(1, 1, 1, alpha), 1, false)
        end

        ::skip::
    end
end

local renderCollback = ModCallbacks.MC_POST_RENDER
if Renderer then    -- RGON
    renderCollback = ModCallbacks.MC_HUD_RENDER
end

Astro:AddCallback(renderCollback, function()
    BuildPocketItemStrings()
    RenderPocketItemName()
end)
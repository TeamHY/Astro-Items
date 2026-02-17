-- 사왈이 제작
Astro.EID.EnglishDescAI = require "astro.collectibles.eid-draft-translation"
Astro.EID.AccurateItemDesc = require "astro.collectibles.eid-accurate-blurbs"
Astro.EID.AccurateTrinketDesc = require "astro.trinkets.eid-accurate-blurbs"

------ VS ------
local minibossNames = {
    [EntityType.ENTITY_SLOTH] = {
        [0] = "나태",
        [1] = "초 나태",
        [2] = "왕 교만"
    },
    [EntityType.ENTITY_LUST] = {
        [0] = "성욕",
        [1] = "초 성욕"
    },
    [EntityType.ENTITY_WRATH] = {
        [0] = "분노",
        [1] = "초 분노"
    },
    [EntityType.ENTITY_GLUTTONY] = {
        [0] = "대식",
        [1] = "초 대식"
    },
    [EntityType.ENTITY_GREED] = {
        [0] = "탐욕",
        [1] = "초 탐욕"
    },
    [EntityType.ENTITY_ENVY] = {
        [0] = "질투",
        [1] = "초 질투"
    },
    [EntityType.ENTITY_PRIDE] = {
        [0] = "교만",
        [1] = "초 교만"
    },
    [EntityType.ENTITY_FALLEN] = {
        [1] = "크람푸스"
    }
}

local playerNames = {
    [Astro.Players.LEAH] = "레아",
    [Astro.Players.LEAH_B] = "라헬",
    [Astro.Players.DIABELLSTAR] = "디아벨스타",
    [Astro.Players.DIABELLSTAR_B] = "디아벨제",
    [Astro.Players.WATER_ENCHANTRESS] = "성전의 수견사",
    [Astro.Players.WATER_ENCHANTRESS_B] = "일리걸 나이트",
    [Astro.Players.DAVID_MARTINEZ] = "데이비드",
    [Astro.Players.DAVID_MARTINEZ_B] = "루시",
    [Astro.Players.STELLAR] = "스텔라",
    [Astro.Players.STELLAR_B] = "나유타",
    [Astro.Players.AINZ_OOAL_GOWN] = "아인즈",
    [Astro.Players.AINZ_OOAL_GOWN_B] = "판도라즈 액터",
}

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        local player = Isaac.GetPlayer(0)    -- 0번 컨트롤러의 화면에서 표시되어야 하므로
        local pType = player:GetPlayerType()
        if not playerNames[pType] then return end
        if Options.Language ~= "kr" or not REPKOR then return end

        local room = Game():GetRoom()
        local rType = room:GetType()
        if rType ~= RoomType.ROOM_SHOP and
           rType ~= RoomType.ROOM_DEVIL and
           rType ~= RoomType.ROOM_MINIBOSS and
           rType ~= RoomType.ROOM_SECRET
        then return end

        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if ent:IsActiveEnemy() and minibossNames[ent.Type] then
                local playerName = playerNames[pType] or player:GetName()

                local nameTable = minibossNames[ent.Type]
                local vb = ent.Variant or 0
                local minibossName = nameTable[vb] or nameTable[0]

                Game():GetHUD():ShowItemText(playerName .. " VS " .. minibossName)
                break
            end
        end
    end
)

------ 포켓 아이템 ------
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

Astro.pocketItemStr = {}

local function BuildPocketItemStrings()
    Astro.pocketItemStr = {}

    local ic = Isaac.GetItemConfig()
    local numPlayers = Game():GetNumPlayers()

    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)
        if not player or not player:Exists() or not player:ToPlayer() then
            goto skip
        end

        local TrslName = nil
        local card = player:GetCard(0)
        local pill = player:GetPill(0)

        if card ~= 0 then
            goto skip
        elseif pill ~= 0 and pill ~= 14 then
            goto skip
        else
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
        end

        local id = #Astro.pocketItemStr + 1
        Astro.pocketItemStr[id] = {
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
        Astro.pocketItemStr = {}
    end 
end)

local font = Font()
font:Load(Astro.ModPath .. "resources/font/for translate/luaminioutlined.fnt")

local function RenderPocketItemName()
    if not Game():GetHUD():IsVisible() then return end
    if Game():GetNumPlayers() > 1 then return end    -- 멀티 유기

    local shakeOffset = Game().ScreenShakeOffset
    local fontSize, sizeOffset = 1, -2

    for i, k in pairs(Astro.pocketItemStr) do
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
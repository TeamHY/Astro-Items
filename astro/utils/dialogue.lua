---

local DEFAULT_DURATION = 75
local FADE_OUT_DURATION = 30
local TYPING_SPEED = 1
local LINE_WIDTH = 200
local LINE_HEIGHT = 14
local RENDER_OFFSET = Vector(0, -40)
local TYPING_SOUND = Astro.SoundEffect.DIALOGUE_TYPING
local TYPING_SOUND_VOLUME = 2
local TYPING_SOUND_PITCH = 1
local TYPING_SOUND_INTERVAL = 1

---

local font = Font()
font:Load(Astro.ModPath .. "resources/font/eid_korean_galmoori9.fnt")

local function LogDialogue(message)
    if Astro.DebugDialogue then
        Isaac.DebugString("[AstroItems][Dialogue] frame=" .. Game():GetFrameCount() .. " " .. message)
    end
end

Isaac.DebugString("[AstroItems][Dialogue] loaded fontLoaded=" .. tostring(font:IsLoaded()))

---@type { entity: Entity, font: Font, lines: string[][], totalLength: integer, charIndex: integer, timer: integer, duration: integer, alpha: number }[]
local activeDialogues = {}

---@param text string
---@return string[]
local function SplitCharacters(text)
    local characters = {}
    local index = 1

    while index <= #text do
        local byte = string.byte(text, index)
        local size = 1

        if byte >= 0xF0 then
            size = 4
        elseif byte >= 0xE0 then
            size = 3
        elseif byte >= 0xC0 then
            size = 2
        end

        table.insert(characters, string.sub(text, index, index + size - 1))
        index = index + size
    end

    return characters
end

---@param text string
---@param dialogueFont Font
---@return string[][]
local function WrapText(text, dialogueFont)
    local lines = {}
    local currentLine = ""

    -- 로케일에 따라 %s가 한글 UTF-8 바이트를 공백으로 판단하지 않도록 합니다.
    for word in string.gmatch(text, "[^ \t\n\r\f\v]+") do
        local testLine = currentLine == "" and word or (currentLine .. " " .. word)

        if currentLine ~= "" and dialogueFont:GetStringWidthUTF8(testLine) > LINE_WIDTH then
            table.insert(lines, SplitCharacters(currentLine))
            currentLine = word
        else
            currentLine = testLine
        end
    end

    if currentLine ~= "" then
        table.insert(lines, SplitCharacters(currentLine))
    end

    return lines
end

---@param t number
---@return number
local function EaseInOutQuad(t)
    return t < 0.5 and 2 * t * t or 1 - ((-2 * t + 2) ^ 2) / 2
end

---@param entity Entity
---@return integer?
local function FindDialogueIndex(entity)
    for index, dialogue in ipairs(activeDialogues) do
        if GetPtrHash(dialogue.entity) == GetPtrHash(entity) then
            return index
        end
    end
end

---@param entity Entity
---@param text string
---@param duration integer?
---@param dialogueFont Font?
function Astro:ShowDialogue(entity, text, duration, dialogueFont)
    if not entity or not entity:Exists() or text == nil or text == "" then
        LogDialogue("show.skip entityExists=" .. tostring(entity ~= nil and entity:Exists()) .. " text=" .. tostring(text))
        return
    end

    dialogueFont = dialogueFont or font
    local lines = WrapText(text, dialogueFont)
    local totalLength = 0

    for _, line in ipairs(lines) do
        totalLength = totalLength + #line
    end

    local dialogue = {
        entity = entity,
        font = dialogueFont,
        lines = lines,
        totalLength = totalLength,
        charIndex = 0,
        timer = 0,
        duration = duration or DEFAULT_DURATION,
        alpha = 1.0
    }

    local index = FindDialogueIndex(entity)

    if index then
        activeDialogues[index] = dialogue
    else
        table.insert(activeDialogues, dialogue)
    end

    LogDialogue(string.format("show.accepted entity=%s lines=%d chars=%d duration=%d replaced=%s text=%s",
        tostring(GetPtrHash(entity)), #lines, totalLength, dialogue.duration, tostring(index ~= nil), text))
end

---@param entity Entity
function Astro:HideDialogue(entity)
    local index = FindDialogueIndex(entity)

    if index then
        LogDialogue("hide entity=" .. tostring(GetPtrHash(entity)))
        table.remove(activeDialogues, index)
    end
end

---@param entity Entity
---@return boolean
function Astro:IsDialogueActive(entity)
    return FindDialogueIndex(entity) ~= nil
end

---@param entity Entity
---@return boolean
function Astro:IsDialogueTyping(entity)
    local index = FindDialogueIndex(entity)
    local dialogue = index and activeDialogues[index]

    return dialogue ~= nil and dialogue.charIndex < dialogue.totalLength
end

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        for index = #activeDialogues, 1, -1 do
            local dialogue = activeDialogues[index]

            if not dialogue.entity:Exists() then
                LogDialogue("update.remove reason=entity-gone")
                table.remove(activeDialogues, index)
            elseif dialogue.charIndex < dialogue.totalLength then
                if dialogue.charIndex == 0 then
                    LogDialogue("update.typing entity=" .. tostring(GetPtrHash(dialogue.entity)))
                end
                dialogue.charIndex = math.min(dialogue.charIndex + TYPING_SPEED, dialogue.totalLength)

                if dialogue.charIndex % TYPING_SOUND_INTERVAL == 0 then
                    SFXManager():Play(TYPING_SOUND, TYPING_SOUND_VOLUME, 0, false, TYPING_SOUND_PITCH)
                end

                if dialogue.charIndex == dialogue.totalLength then
                    LogDialogue("update.typing-complete entity=" .. tostring(GetPtrHash(dialogue.entity)))
                end
            else
                dialogue.timer = dialogue.timer + 1

                if dialogue.timer > dialogue.duration then
                    local elapsed = dialogue.timer - dialogue.duration

                    if elapsed >= FADE_OUT_DURATION then
                        LogDialogue("update.remove reason=expired entity=" .. tostring(GetPtrHash(dialogue.entity)))
                        table.remove(activeDialogues, index)
                    else
                        dialogue.alpha = 1.0 - EaseInOutQuad(elapsed / FADE_OUT_DURATION)
                    end
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        LogDialogue("new-room.clear active=" .. #activeDialogues)
        activeDialogues = {}
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        if not Game():GetHUD():IsVisible() then
            for _, dialogue in ipairs(activeDialogues) do
                if not dialogue.loggedHiddenHUD then
                    LogDialogue("render.skip reason=hud-hidden entity=" .. tostring(GetPtrHash(dialogue.entity)))
                    dialogue.loggedHiddenHUD = true
                end
            end
            return
        end

        for _, dialogue in ipairs(activeDialogues) do
            local position = Astro:ToScreen(dialogue.entity.Position) + RENDER_OFFSET
            local baseX = position.X - LINE_WIDTH / 2
            local baseY = position.Y - (#dialogue.lines - 1) * LINE_HEIGHT
            local color = KColor(1, 1, 1, dialogue.alpha)
            local remaining = dialogue.charIndex

            for lineIndex, line in ipairs(dialogue.lines) do
                if remaining <= 0 then
                    break
                end

                local count = math.min(remaining, #line)

                dialogue.font:DrawStringUTF8(
                    table.concat(line, "", 1, count),
                    baseX,
                    baseY + (lineIndex - 1) * LINE_HEIGHT,
                    color,
                    LINE_WIDTH,
                    true
                )

                remaining = remaining - count
            end

            if dialogue.charIndex > 0 and not dialogue.loggedRender then
                LogDialogue(string.format("render.drawn entity=%s x=%.1f y=%.1f chars=%d lines=%d",
                    tostring(GetPtrHash(dialogue.entity)), position.X, baseY, dialogue.charIndex, #dialogue.lines))
                dialogue.loggedRender = true
            end
        end
    end
)

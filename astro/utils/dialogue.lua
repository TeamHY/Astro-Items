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

---@type { entity: Entity, lines: string[][], totalLength: integer, charIndex: integer, timer: integer, duration: integer, alpha: number }[]
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
---@return string[][]
local function WrapText(text)
    local lines = {}
    local currentLine = ""

    for word in string.gmatch(text, "[^%s]+") do
        local testLine = currentLine == "" and word or (currentLine .. " " .. word)

        if currentLine ~= "" and font:GetStringWidthUTF8(testLine) > LINE_WIDTH then
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
function Astro:ShowDialogue(entity, text, duration)
    if not entity or not entity:Exists() or text == nil or text == "" then
        return
    end

    local lines = WrapText(text)
    local totalLength = 0

    for _, line in ipairs(lines) do
        totalLength = totalLength + #line
    end

    local dialogue = {
        entity = entity,
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
end

---@param entity Entity
function Astro:HideDialogue(entity)
    local index = FindDialogueIndex(entity)

    if index then
        table.remove(activeDialogues, index)
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        for index = #activeDialogues, 1, -1 do
            local dialogue = activeDialogues[index]

            if not dialogue.entity:Exists() then
                table.remove(activeDialogues, index)
            elseif dialogue.charIndex < dialogue.totalLength then
                dialogue.charIndex = math.min(dialogue.charIndex + TYPING_SPEED, dialogue.totalLength)

                if dialogue.charIndex % TYPING_SOUND_INTERVAL == 0 then
                    SFXManager():Play(TYPING_SOUND, TYPING_SOUND_VOLUME, 0, false, TYPING_SOUND_PITCH)
                end
            else
                dialogue.timer = dialogue.timer + 1

                if dialogue.timer > dialogue.duration then
                    local elapsed = dialogue.timer - dialogue.duration

                    if elapsed >= FADE_OUT_DURATION then
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
        activeDialogues = {}
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        if not Game():GetHUD():IsVisible() then
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

                font:DrawStringUTF8(
                    table.concat(line, "", 1, count),
                    baseX,
                    baseY + (lineIndex - 1) * LINE_HEIGHT,
                    color,
                    LINE_WIDTH,
                    true
                )

                remaining = remaining - count
            end
        end
    end
)

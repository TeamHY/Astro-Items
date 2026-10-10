---

local DURATION = 150

local FADE_IN = 10

local FADE_OUT = 40

local Y_FROM_BOTTOM = 50

local LINE_HEIGHT = 15

local MAX_MESSAGES = 5

local TEXT_COLOR = { 1, 1, 1 }

local BACKGROUND_ALPHA = 0.75

---

local font = Font()
font:Load(Astro.ModPath .. "resources/font/eid_korean_galmoori9.fnt")

local pixelSprite = Sprite()
pixelSprite:Load("gfx/ui/pixel.anm2", true)
pixelSprite:SetFrame("Idle", 0)

---@type { text: string, time: integer, color: number[] }[]
local messages = {}

local function IsQuickStreamingAvailable()
    return QuickStreaming ~= nil and QuickStreaming.EventNotify ~= nil and QuickStreaming.EventNotify.Show ~= nil
end

---@param text string
---@param color number[]? { r, g, b }
function Astro:ShowNotification(text, color)
    if IsQuickStreamingAvailable() then
        QuickStreaming.EventNotify.Show(text, color)
        return
    end

    table.insert(messages, { text = text, time = Game():GetFrameCount(), color = color or TEXT_COLOR })

    if #messages > MAX_MESSAGES then
        table.remove(messages, 1)
    end
end

local function DrawRect(x, y, w, h, a)
    pixelSprite.Scale = Vector(w, h)
    pixelSprite.Color = Color(0, 0, 0, a)
    pixelSprite:Render(Vector(x, y))
end

local function GetBaseScale()
    local scaleMulti = Isaac.GetScreenPointScale()

    if scaleMulti == 1 then
        return 1
    elseif scaleMulti == 2 then
        return 0.5
    elseif scaleMulti == 3 then
        return 2 / 3
    end

    return 0.75
end

---@param message { text: string, time: integer, color: number[] }
---@param yOffset number
local function RenderMessage(message, yOffset)
    local duration = Game():GetFrameCount() - message.time
    local baseScale = GetBaseScale()
    local alpha = 1
    local yFade = 0

    if duration <= FADE_IN then
        local percent = duration / FADE_IN

        yFade = (1 - math.sin(percent * math.pi / 2)) * 10
        alpha = percent
    end

    if DURATION - duration <= FADE_OUT then
        alpha = (DURATION - duration) / FADE_OUT
    end

    local stringWidth = font:GetStringWidthUTF8(message.text) * baseScale
    local stringHeight = font:GetBaselineHeight() * baseScale

    local pos = Vector(
        Isaac.GetScreenWidth() / 2 - stringWidth / 2,
        Isaac.GetScreenHeight() - Y_FROM_BOTTOM + (yOffset + yFade) * baseScale
    ) + Game().ScreenShakeOffset

    DrawRect(
        pos.X - 3 * baseScale,
        pos.Y - 1.5 * baseScale,
        stringWidth + 6 * baseScale,
        stringHeight + 6 * baseScale,
        alpha * BACKGROUND_ALPHA
    )

    font:DrawStringScaledUTF8(
        message.text,
        pos.X, pos.Y,
        baseScale, baseScale,
        KColor(message.color[1], message.color[2], message.color[3], alpha),
        0,
        false
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function()
        if #messages == 0 then return end

        local frame = Game():GetFrameCount()

        for i = #messages, 1, -1 do
            if frame - messages[i].time >= DURATION then
                table.remove(messages, i)
            end
        end

        for i, message in ipairs(messages) do
            RenderMessage(message, (i - #messages) * LINE_HEIGHT)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function()
        messages = {}
    end
)

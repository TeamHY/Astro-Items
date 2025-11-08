---@class MegaUIConfig
---@field anm2Path string
---@field choiceCount integer
---@field itemId CollectibleType
---@field onChoiceSelected fun(player: EntityPlayer, choice: integer) 선택지가 선택될 때 호출되는 콜백

---@class MegaUIInstance
---@field config MegaUIConfig
---@field iconSpacing integer
---@field bgSprite Sprite
---@field selectSprite Sprite
---@field iconSprites Sprite[]
---@field anim {active: boolean, dir: integer, t: integer, duration: integer, startSelected: integer, targetSelected: integer}
---@field state {isOpen: boolean, playerIndex: integer|nil, frame: integer, selected: integer, confirmDelay: integer, fadeInFrame: integer, fadeOutFrame: integer, isClosing: boolean}
local MegaUIInstance = {}
MegaUIInstance.__index = MegaUIInstance

Astro.MegaUI = {}

---@param config MegaUIConfig
---@return MegaUIInstance
function Astro.MegaUI:CreateInstance(config)
    local instance = setmetatable({}, MegaUIInstance)

    instance.config = config
    instance.iconSpacing = 32

    Astro:AddCallback(
        ModCallbacks.MC_USE_ITEM,
        ---@param collectible CollectibleType
        ---@param rng RNG
        ---@param player EntityPlayer
        ---@param useFlags integer
        ---@param activeSlot ActiveSlot
        ---@param varData integer
        function(_, collectible, rng, player, useFlags, activeSlot, varData)
            if instance:TryOpen(player) then
                return {Discharge = false, Remove = false, ShowAnim = false}
            end

            if not instance:IsClosing() then
                instance:CloseUI()
                instance:ApplyChoice(player)
                return {Discharge = true, Remove = false, ShowAnim = true} 
            end
        end,
        config.itemId
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_RENDER,
        function()
            instance:Render()
        end
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_RENDER,
        function()
            instance:HandleInput()
        end
    )

    Astro:AddCallback(
        ModCallbacks.MC_POST_UPDATE,
        function()
            instance:Update()
        end
    )

    instance.bgSprite = Sprite()
    instance.selectSprite = Sprite()
    instance.bgSprite:Load(config.anm2Path, true)
    instance.bgSprite:Play("open", true)

    instance.selectSprite:Load(config.anm2Path, true)
    instance.selectSprite:Play("select", true)

    ---@type Sprite[]
    instance.iconSprites = {}

    for i = 1, config.choiceCount do
        local sprite = Sprite()
        sprite:Load(config.anm2Path, true)
        sprite:Play("icon", true)
        sprite:SetFrame("icon", i - 1)

        instance.iconSprites[i] = sprite
    end

    instance.anim = {
        active = false,
        dir = 0,
        t = 0,
        duration = 8,
        startSelected = 1,
        targetSelected = 1
    }

    instance.state = {
        isOpen = false,
        playerIndex = nil,
        frame = 0,
        selected = 1,
        confirmDelay = 0,
        fadeInFrame = 0,
        fadeOutFrame = 0,
        isClosing = false
    }

    return instance
end

function MegaUIInstance:ResetUI(player)
    self.state.isOpen = true
    self.state.playerIndex = player.ControllerIndex
    self.state.frame = 0
    self.state.confirmDelay = 0
    self.state.fadeInFrame = 0
    self.state.fadeOutFrame = 0
    self.state.isClosing = false
    self.bgSprite:Play("open", true)
    self.selectSprite:Play("select", true)
    self.anim.active = false
    self.anim.t = 0
    self.anim.dir = 0
    self.anim.startSelected = self.state.selected
    self.anim.targetSelected = self.state.selected
end

---@param player EntityPlayer
---@return boolean success
function MegaUIInstance:TryOpen(player)
    if self.state.isOpen then
        return false
    end
    self:ResetUI(player)
    return true
end

function MegaUIInstance:CloseUI()
    self.state.isClosing = true
    self.state.fadeOutFrame = 0
end

function MegaUIInstance:WrapIndex(i)
    while i < 1 do
        i = i + self.config.choiceCount
    end
    while i > self.config.choiceCount do
        i = i - self.config.choiceCount
    end
    return i
end

function MegaUIInstance:StartSlide(direction)
    if self.anim.active then
        return
    end
    self.anim.active = true
    self.anim.dir = direction
    self.anim.t = 0
    self.anim.startSelected = self.state.selected
    self.anim.targetSelected = self:WrapIndex(self.state.selected + direction)
end

---@return EntityPlayer|nil
function MegaUIInstance:GetPlayer()
    if self.state.playerIndex then
        for i = 1, Game():GetNumPlayers() do
            local p = Isaac.GetPlayer(i - 1)
            if p.ControllerIndex == self.state.playerIndex then
                return p
            end
        end
    end

    self.state.isOpen = false
    self.state.isClosing = false
    self.state.playerIndex = nil

    return nil
end

function MegaUIInstance:ApplyChoice(player)
    self.config.onChoiceSelected(player, self.state.selected)
end

function MegaUIInstance:Update()
    if not self.state.isOpen then
        return
    end

    local player = self:GetPlayer()
    if not player then
        return
    end

    if not player:HasCollectible(self.config.itemId) then
        self.state.isOpen = false
        self.state.isClosing = false
        self.state.playerIndex = nil
    end

    self.bgSprite:Update()
end

function MegaUIInstance:HandleInput()
    if not self.state.isOpen then
        return
    end

    self.state.frame = self.state.frame + 1
    local player = self:GetPlayer()
    if not player then
        return
    end

    local moveLeft = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
    local moveRight = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)
    local cancel = Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)

    if not self.anim.active then
        if moveLeft then
            self:StartSlide(-1)
            SFXManager():Play(SoundEffect.SOUND_CHARACTER_SELECT_LEFT)
        elseif moveRight then
            self:StartSlide(1)
            SFXManager():Play(SoundEffect.SOUND_CHARACTER_SELECT_RIGHT)
        end
    end

    if cancel then
        self:CloseUI()
    end
end

function MegaUIInstance:Render()
    if not self.state.isOpen then
        return
    end

    if self.state.isClosing then
        self.state.fadeOutFrame = self.state.fadeOutFrame + 1
        if self.state.fadeOutFrame >= 24 then
            self.state.isOpen = false
            self.state.isClosing = false
            self.state.playerIndex = nil
            return
        end
    else
        if self.state.fadeInFrame < 24 then
            self.state.fadeInFrame = self.state.fadeInFrame + 1
        end
        if self.bgSprite:IsFinished("open") then
            if not self.bgSprite:IsPlaying("idle") then
                self.bgSprite:Play("idle", true)
            end
        end
    end

    local player = self:GetPlayer()
    if not player then
        return
    end

    local uiCenterPosition = Astro:ToScreen(player.Position + Vector(0, -120))

    local alpha, scale, bgAlpha
    if self.state.isClosing then
        local fadeOutProgress = self.state.fadeOutFrame / 24
        alpha = 1 - fadeOutProgress
        bgAlpha = 1 - fadeOutProgress
        scale = 1
    else
        local fadeInAlpha = math.min((self.state.fadeInFrame - 10) / 14, 1)
        alpha = fadeInAlpha
        bgAlpha = 1
        scale = 0.5 + 0.5 * fadeInAlpha
    end

    if self.anim.active then
        self.anim.t = self.anim.t + 1
        if self.anim.t >= self.anim.duration then
            self.anim.t = self.anim.duration
            self.anim.active = false
            self.state.selected = self.anim.targetSelected
        end
    end
    local linear = self.anim.active and (self.anim.t / self.anim.duration) or 1
    local progress = linear < 0.5 and 2 * linear * linear or -1 + (4 - 2 * linear) * linear

    local bgColor = Color(1, 1, 1, bgAlpha, 0, 0, 0)
    local oldBgColor = self.bgSprite.Color
    self.bgSprite.Color = bgColor
    self.bgSprite:Render(uiCenterPosition)
    self.bgSprite.Color = oldBgColor

    local centerBase = self.anim.active and self.anim.startSelected or self.state.selected
    local centerPos = centerBase
    if self.anim.active then
        centerPos = self.anim.startSelected + self.anim.dir * progress
    end

    local function shortestOffset(index, center)
        local raw = index - center
        while raw > self.config.choiceCount / 2 do
            raw = raw - self.config.choiceCount
        end
        while raw < -self.config.choiceCount / 2 do
            raw = raw + self.config.choiceCount
        end
        return raw
    end

    for i = 1, self.config.choiceCount do
        local offset = shortestOffset(i, centerPos)
        if math.abs(offset) <= 2.6 then
            local sprite = self.iconSprites[i]
            local pos = uiCenterPosition + Vector(offset * self.iconSpacing, 0)
            local absOff = math.abs(offset)
            local iconAlpha
            if absOff < 0.001 then
                iconAlpha = 1
            elseif absOff < 1.1 then
                iconAlpha = 0.8 + 0.2 * (1 - (absOff - 0.0))
            elseif absOff < 2.1 then
                iconAlpha = 0.5 + 0.3 * (2.1 - absOff)
            else
                iconAlpha = 0.3
            end
            iconAlpha = iconAlpha * alpha
            local oldColor = sprite.Color
            local oldScale = sprite.Scale
            sprite.Color = Color(1, 1, 1, iconAlpha, 0, 0, 0)
            sprite.Scale = Vector(scale, scale)
            sprite:Render(pos)
            sprite.Color = oldColor
            sprite.Scale = oldScale
        end
    end

    self.selectSprite:SetAnimation("select")
    self.selectSprite:SetFrame(0)
    local selectColor = Color(1, 1, 1, alpha, 0, 0, 0)
    local oldSelectColor = self.selectSprite.Color
    local oldSelectScale = self.selectSprite.Scale
    self.selectSprite.Color = selectColor
    self.selectSprite.Scale = Vector(scale, scale)
    self.selectSprite:Render(uiCenterPosition)
    self.selectSprite.Color = oldSelectColor
    self.selectSprite.Scale = oldSelectScale
end

function MegaUIInstance:IsOpen()
    return self.state.isOpen
end

function MegaUIInstance:IsClosing()
    return self.state.isClosing
end

local SpringAnimation = {}
SpringAnimation.__index = SpringAnimation

function SpringAnimation:new(initialValue, springConstant, damping, mass)
    local spring = {
        value = initialValue or 0,
        velocity = 0,
        target = initialValue or 0,
        springConstant = springConstant or 200,
        damping = damping or 20,
        mass = mass or 1
    }
    setmetatable(spring, self)
    return spring
end

function SpringAnimation:SetTarget(target)
    self.target = target
end

function SpringAnimation:Update(deltaTime)
    local displacement = self.target - self.value
    local springForce = self.springConstant * displacement
    local dampingForce = -self.damping * self.velocity
    local totalForce = springForce + dampingForce

    local acceleration = totalForce / self.mass
    self.velocity = self.velocity + acceleration * deltaTime
    self.value = self.value + self.velocity * deltaTime
end

function SpringAnimation:IsSettled(threshold)
    threshold = threshold or 0.01
    local displacement = math.abs(self.target - self.value)
    local velocityMagnitude = math.abs(self.velocity)
    return displacement < threshold and velocityMagnitude < threshold
end

function SpringAnimation:GetValue()
    return self.value
end

function SpringAnimation:SetValue(value)
    self.value = value
    self.velocity = 0
end

function SpringAnimation:SetParameters(springConstant, damping, mass)
    self.springConstant = springConstant
    self.damping = damping
    if mass then
        self.mass = mass
    end
end

SpringAnimation.Presets = {
    BOUNCY = { springConstant = 400, damping = 15, mass = 1 },
    SMOOTH = { springConstant = 200, damping = 25, mass = 1 },
    GENTLE = { springConstant = 100, damping = 20, mass = 1 },
    SNAPPY = { springConstant = 300, damping = 30, mass = 1 }
}

function SpringAnimation:FromPreset(initialValue, preset)
    return SpringAnimation:new(initialValue, preset.springConstant, preset.damping, preset.mass)
end

local SpringVector2D = {}
SpringVector2D.__index = SpringVector2D

function SpringVector2D:new(initialVector, springConstant, damping, mass)
    local springVector = {
        x = SpringAnimation:new(initialVector.X, springConstant, damping, mass),
        y = SpringAnimation:new(initialVector.Y, springConstant, damping, mass)
    }
    setmetatable(springVector, self)
    return springVector
end

function SpringVector2D:SetTarget(targetVector)
    self.x:SetTarget(targetVector.X)
    self.y:SetTarget(targetVector.Y)
end

function SpringVector2D:Update(deltaTime)
    self.x:Update(deltaTime)
    self.y:Update(deltaTime)
end

function SpringVector2D:GetVector()
    return Vector(self.x:GetValue(), self.y:GetValue())
end

function SpringVector2D:IsSettled(threshold)
    return self.x:IsSettled(threshold) and self.y:IsSettled(threshold)
end

local SpringRotation = {}
SpringRotation.__index = SpringRotation

function SpringRotation:new(initialAngle, springConstant, damping, mass)
    local spring = {
        angle = initialAngle or 0,
        velocity = 0,
        target = initialAngle or 0,
        springConstant = springConstant or 200,
        damping = damping or 20,
        mass = mass or 1
    }
    setmetatable(spring, self)
    return spring
end

local function NormalizeAngle(angle)
    while angle < 0 do
        angle = angle + 360
    end
    while angle >= 360 do
        angle = angle - 360
    end
    return angle
end

local function GetShortestAngularDistance(current, target)
    local diff = target - current
    if diff > 180 then
        diff = diff - 360
    elseif diff < -180 then
        diff = diff + 360
    end
    return diff
end

function SpringRotation:SetTarget(targetAngle)
    self.target = NormalizeAngle(targetAngle)
end

function SpringRotation:Update(deltaTime)
    local displacement = GetShortestAngularDistance(self.angle, self.target)
    local springForce = self.springConstant * displacement
    local dampingForce = -self.damping * self.velocity
    local totalForce = springForce + dampingForce

    local acceleration = totalForce / self.mass
    self.velocity = self.velocity + acceleration * deltaTime
    self.angle = self.angle + self.velocity * deltaTime
    self.angle = NormalizeAngle(self.angle)
end

function SpringRotation:IsSettled(threshold)
    threshold = threshold or 0.5
    local displacement = math.abs(GetShortestAngularDistance(self.angle, self.target))
    local velocityMagnitude = math.abs(self.velocity)
    return displacement < threshold and velocityMagnitude < threshold
end

function SpringRotation:GetAngle()
    return self.angle
end

function SpringRotation:SetAngle(angle)
    self.angle = NormalizeAngle(angle)
    self.velocity = 0
end

function SpringRotation:SetParameters(springConstant, damping, mass)
    self.springConstant = springConstant
    self.damping = damping
    if mass then
        self.mass = mass
    end
end

function SpringRotation:FromPreset(initialAngle, preset)
    return SpringRotation:new(initialAngle, preset.springConstant, preset.damping, preset.mass)
end

return {
    SpringAnimation = SpringAnimation,
    SpringVector2D = SpringVector2D,
    SpringRotation = SpringRotation
}
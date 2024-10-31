-- https://stackoverflow.com/questions/25597818

local Noise = {}

Astro.Noise = Noise

---@param list integer[]
function Noise:GetSimpleHash(list)
    local hash = 80238287;

    for _, value in ipairs(list) do
      hash = (hash << 4) ~ (hash >> 28) ~ (value * 5449 % 130651);
    end

    return hash % 75327403;
end

function Noise:GetWhiteNoise(x, y)
    math.randomseed(self:GetSimpleHash({ x, y }))
    return math.random()
end

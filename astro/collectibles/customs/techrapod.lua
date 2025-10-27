---

local LASER_RANGE = 80

local LASER_DAMAGE_MULTIPLY = 1

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.TECHRAPOD = Isaac.GetItemIdByName("Techrapod")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.TECHRAPOD,
                "테크라포드",
                "삼각 레이저",
                "캐릭터 주변에 정삼각형 모양의 레이저가 생깁니다." ..
                "#레이저는 적을 관통하며, 프레임당 캐릭터의 공격력 x0.n의 피해를 줍니다.",
                -- 중첩 시
                "중첩할수록 레이저의 굵기 증가"
            )
        end
    end
)

---@param player EntityPlayer
local function SpawnLasers(player)
    local distance = Vector(LASER_RANGE, 0):Distance(Vector.FromAngle(120) * LASER_RANGE) - 20

    for i = 1, 3 do
        local angle = (i - 1) * 120 + 90
        local position = player.Position + Vector.FromAngle(angle) * LASER_RANGE
        local laser = player:FireTechLaser(position, LaserOffset.LASER_TECH1_OFFSET, Vector.FromAngle(angle - 150), nil, nil, player, LASER_DAMAGE_MULTIPLY)
        laser:GetData().AstroTechrapodLaser = { index = i}
        laser:SetTimeout(999999999999)
        laser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        laser.MaxDistance = distance
    end
end

---@param player EntityPlayer
local function GetLasers(player)
    local lasers = Isaac.FindByType(EntityType.ENTITY_LASER, -1, -1, true)
    local result = {} ---@type EntityLaser[]

    for _, laser in ipairs(lasers) do
        local laserEntity = laser:ToLaser() ---@cast laserEntity EntityLaser
        local data = laserEntity:GetData()

        print(data.AstroTechrapodLaser)

        if data.AstroTechrapodLaser and laserEntity.Parent:ToPlayer():GetPlayerIndex() == player:GetPlayerIndex() then
            table.insert(result, laserEntity)
        end
    end

    return result
end

---@param player EntityPlayer
local function RemoveLasers(player)
    local lasers = GetLasers(player)

    for _, laser in ipairs(lasers) do
        laser:Die()
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.TECHRAPOD) then
                SpawnLasers(player)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if #GetLasers(player) == 0 then
            SpawnLasers(player)
        end
    end,
    Astro.Collectible.TECHRAPOD
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not player:HasCollectible(Astro.Collectible.TECHRAPOD) then
            RemoveLasers(player)
        end
    end,
    Astro.Collectible.TECHRAPOD
)

---@param laser EntityLaser
local function UpdateLaser(laser)
    local data = laser:GetData()

    if data.AstroTechrapodLaser then
        local player = laser.Parent:ToPlayer()

        if not player then
            return
        end

        local index = data.AstroTechrapodLaser.index
        local angle = (index - 1) * 120 - 90

        laser.Position = player.Position + Vector.FromAngle(angle) * LASER_RANGE
        laser.Velocity = player.Velocity
        laser.Angle = angle - 150

        if REPENTOGON then
            laser:SetScale(player:GetCollectibleNum(Astro.Collectible.TECHRAPOD))
        end
    end
end

if REPENTOGON then
    Astro:AddCallback(
        ModCallbacks.MC_PRE_LASER_UPDATE,
        ---@param laser EntityLaser
        function(_, laser)
            UpdateLaser(laser)
        end
    )
else
    Astro:AddCallback(
        ModCallbacks.MC_POST_LASER_UPDATE,
        ---@param laser EntityLaser
        function(_, laser)
            UpdateLaser(laser)
        end
    )
end

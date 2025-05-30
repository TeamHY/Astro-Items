---

local USE_SOUND = Astro.SoundEffect.STAFF_OF_AINZ_OOAL_GOWN

local USE_SOUND_VOLUME = 1

local CHARGE_MULTIPLY = 0.2 -- 대미지 당 충전량 비율

---

Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN = Isaac.GetItemIdByName("Staff of Ainz Ooal Gown")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN,
                "스태프 오브 아인즈 울 고운",
                "...",
                "사용 시 방 중앙에 블랙홀을 생성하고 10초 동안 무적이 됩니다." ..
                "#{{Collectible647}} 일반적인 방법으로 충전되지 않고 적에게 입힌 피해량 만큼 충전됩니다."
            )
        end
    end
)

---@param player EntityPlayer
---@param charge number
local function UpdateCharge(player, charge)
    for i = 0, ActiveSlot.SLOT_POCKET2 do
        if player:GetActiveItem(i) == Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN then
            player:SetActiveCharge(math.floor(charge), i)
        end
    end
end

Astro:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        local player = Astro:GetPlayerFromEntity(source.Entity)

        if
            player ~= nil and player:HasCollectible(Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN) and
                entity:IsVulnerableEnemy() and
                entity.Type ~= EntityType.ENTITY_FIREPLACE
         then
            if not (source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.BLACK_HOLE) then
                local data = Astro:GetPersistentPlayerData(player)

                if data.StaffOfAinzOoalGown == nil then
                    data.StaffOfAinzOoalGown = 0
                end

                data.StaffOfAinzOoalGown = data.StaffOfAinzOoalGown + amount * CHARGE_MULTIPLY

                if data.StaffOfAinzOoalGown >= 100 then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
                        if data.StaffOfAinzOoalGown >= 200 then
                            data.StaffOfAinzOoalGown = 200
                        end
                    else
                        data.StaffOfAinzOoalGown = 100
                    end
                end 

                UpdateCharge(player, data.StaffOfAinzOoalGown)
            end
        end
    end
)

local enableRealBlackHole = false

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN) then
                local data = Astro:GetPersistentPlayerData(player)

                if data.StaffOfAinzOoalGown == nil then
                    data.StaffOfAinzOoalGown = 0
                end

                UpdateCharge(player, data.StaffOfAinzOoalGown)
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local data = Astro:GetPersistentPlayerData(playerWhoUsedItem)

        if not (data.StaffOfAinzOoalGown and data.StaffOfAinzOoalGown >= 100) then
            return {
                Discharge = true,
                Remove = false,
                ShowAnim = false,
            }
        end

        data.StaffOfAinzOoalGown = data.StaffOfAinzOoalGown - 100
        enableRealBlackHole = true

        playerWhoUsedItem:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, false)

        local room = Game():GetRoom()
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLACK_HOLE, 0, room:GetCenterPos(), Vector.Zero, nil)

        SFXManager():Play(USE_SOUND, USE_SOUND_VOLUME)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end,
    Astro.Collectible.STAFF_OF_AINZ_OOAL_GOWN
)

local ShaderData = {
    blackHole = false,
    blackHolePosition = Vector.Zero,
    blackHolePositionShader = Vector.Zero,
    blackHoleTime = 0,
    blackHoleSize = 1
}

Astro:AddCallback(
    ModCallbacks.MC_GET_SHADER_PARAMS,
    function(_, shaderName)
        if shaderName == "Black_Hole" then
            if ShaderData.blackHole then
                local room = Game():GetRoom()
                local position = room:WorldToScreenPosition(ShaderData.blackHolePositionShader + Vector(0, -3))
                local radius = room:WorldToScreenPosition(ShaderData.blackHolePositionShader + Vector(20, -3))
                local time = ShaderData.blackHoleTime

                local params = {
                    Enabled = 1,
                    BlackPosition = {position.X, position.Y, radius.X},
                    Time = time,
                    WarpCheck = {position.X + 1, position.Y + 1}
                }
                return params
            else
                local params = {
                    Enabled = 0,
                    BlackPosition = {0, 0, 0},
                    Time = 0,
                    WarpCheck = {0, 0}
                }
                return params
            end
        end
    end
)

local function BlackHoleUpdate()
    if ShaderData.blackHole then
        if Game():GetFrameCount() % 2 == 0 then
            Game():MakeShockwave(ShaderData.blackHolePosition, -0.1, 0.0025, 60)
        end
        ShaderData.blackHoleTime =
            math.min(ShaderData.blackHoleSize, ShaderData.blackHoleTime + 10 / 100 * ShaderData.blackHoleSize)
    end
end

local function EnableBlackHole(position, size)
    size = size or 1

    ShaderData.blackHolePosition = position
    ShaderData.blackHolePositionShader = position
    ShaderData.blackHoleTime = 0
    ShaderData.blackHole = true
    ShaderData.blackHoleSize = size

    local room = Game():GetRoom()
    if room:IsMirrorWorld() then
        local ogY = ShaderData.blackHolePositionShader.Y
        local center = room:GetCenterPos()
        local direction = ShaderData.blackHolePositionShader - center
        ShaderData.blackHolePositionShader = center - direction
        ShaderData.blackHolePositionShader.Y = ogY
    end

    Astro:RemoveCallback(ModCallbacks.MC_POST_UPDATE, BlackHoleUpdate)
    Astro:AddCallback(ModCallbacks.MC_POST_UPDATE, BlackHoleUpdate)
end

local function DisableBlackHole(position)
    if (not position) or position:Distance(ShaderData.blackHolePosition) < 0.01 then
        ShaderData.blackHole = false
        Astro:RemoveCallback(ModCallbacks.MC_POST_UPDATE, BlackHoleUpdate)
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        enableRealBlackHole = false
        DisableBlackHole()
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if not enableRealBlackHole then
            return
        end

        local data = effect:GetData()
        local sprite = effect:GetSprite()

        if not data.Init_BH and sprite:IsPlaying("Init") then
            data.Init_BH = true

            EnableBlackHole(effect.Position)
        end

        if not data.Stop_BH and sprite:IsPlaying("Death") then
            data.Stop_BH = true

            DisableBlackHole(effect.Position)
        end
    end,
    EffectVariant.BLACK_HOLE
)

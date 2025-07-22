local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.ZOLTRAAK = Isaac.GetItemIdByName("Zoltraak")

local ZOLTRAAK_STAFF_VARIANT = 3104

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.ZOLTRAAK,
        "졸트라크",
        "일반적인 공격마법",
        "기본 효과입니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.ZOLTRAAK
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local player = effect.Parent:ToPlayer()

        if not player then return end

        local shootingInput = player:GetShootingInput()
        
        -- 공격키 입력이 있을 때 방향 전환
        if shootingInput.X ~= 0 or shootingInput.Y ~= 0 then
            local sprite = effect:GetSprite()
            
            -- 8방향으로 분기
            if shootingInput.X > 0 and shootingInput.Y == 0 then
                -- 오른쪽 (0도)
                sprite.Rotation = 0
            elseif shootingInput.X > 0 and shootingInput.Y > 0 then
                -- 오른쪽 아래 (45도)
                sprite.Rotation = 45
            elseif shootingInput.X == 0 and shootingInput.Y > 0 then
                -- 아래 (90도)
                sprite.Rotation = 90
            elseif shootingInput.X < 0 and shootingInput.Y > 0 then
                -- 왼쪽 아래 (135도)
                sprite.Rotation = 135
            elseif shootingInput.X < 0 and shootingInput.Y == 0 then
                -- 왼쪽 (180도)
                sprite.Rotation = 180
            elseif shootingInput.X < 0 and shootingInput.Y < 0 then
                -- 왼쪽 위 (225도)
                sprite.Rotation = 225
            elseif shootingInput.X == 0 and shootingInput.Y < 0 then
                -- 위 (270도)
                sprite.Rotation = 270
            elseif shootingInput.X > 0 and shootingInput.Y < 0 then
                -- 오른쪽 위 (315도)
                sprite.Rotation = 315
            end
        end
    end,
    ZOLTRAAK_STAFF_VARIANT
)


Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local staff = Isaac.Spawn(EntityType.ENTITY_EFFECT, ZOLTRAAK_STAFF_VARIANT, 0, player.Position, Vector.Zero, player)
        staff.Parent = player

        local sprite = staff:GetSprite()
        sprite:Play("Rotation", true)
        sprite:Stop()
    end,
    Astro.Collectible.ZOLTRAAK
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        -- 아이템 제거 시 효과
    end,
    Astro.Collectible.ZOLTRAAK
)

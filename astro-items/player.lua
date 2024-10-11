-- local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Players = {
    LEAH = Isaac.GetPlayerTypeByName("Leah"),
    LEAH_B = Isaac.GetPlayerTypeByName("Tainted Leah", true),
    DIABELLSTAR = Isaac.GetPlayerTypeByName("Diabellstar"),
    DIABELLSTAR_B = Isaac.GetPlayerTypeByName("Tainted Diabellstar", true),
    WATER_ENCHANTRESS = Isaac.GetPlayerTypeByName("Water Enchantress"),
    WATER_ENCHANTRESS_B = Isaac.GetPlayerTypeByName("Tainted Water Enchantress", true),
    DAVID_MARTINEZ = Isaac.GetPlayerTypeByName("David Martinez"),
    DAVID_MARTINEZ_B = Isaac.GetPlayerTypeByName("Tainted David Martinez", true),
    STELLAR = Isaac.GetPlayerTypeByName("Stellar"),
    STELLAR_B = Isaac.GetPlayerTypeByName("Tainted Stellar", true),
}

local LEAH_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_leahb_hair.anm2")
local DIABELLSTAR_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_diabellstar_hair.anm2")
local DIABELLSTAR_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_diabellstarb_hair.anm2")
local WATER_ENCHANTRESS_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_water_enchantress_hair.anm2")
local WATER_ENCHANTRESS_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_water_enchantressb_hair.anm2")
local DAVID_MARTINEZ_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_david_martinez_hair.anm2")
local DAVID_MARTINEZ_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_david_martinezb_hair.anm2")
local STELLAR_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_stellar_hair.anm2")
local STELLAR_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_stellarb_hair.anm2")

local EFFECT_STAR_VARIANT = Isaac.GetEntityVariantByName("Effect Star");
local EFFECT_DUST_VARIANT = Isaac.GetEntityVariantByName("Effect Dust");

---@param player EntityPlayer
function AstroItems:IsLeah(player)
    return player:GetPlayerType() == AstroItems.Players.LEAH or player:GetPlayerType() == AstroItems.Players.LEAH_B
end

---@param player EntityPlayer
function AstroItems:IsDiabellstar(player)
    return player:GetPlayerType() == AstroItems.Players.DIABELLSTAR or player:GetPlayerType() == AstroItems.Players.DIABELLSTAR_B
end

---@param player EntityPlayer
function AstroItems:IsWaterEnchantress(player)
    return player:GetPlayerType() == AstroItems.Players.WATER_ENCHANTRESS or player:GetPlayerType() == AstroItems.Players.WATER_ENCHANTRESS_B
end

---@param player EntityPlayer
function AstroItems:IsDavidMartinez(player)
    return player:GetPlayerType() == AstroItems.Players.DAVID_MARTINEZ or player:GetPlayerType() == AstroItems.Players.DAVID_MARTINEZ_B
end

---@param player EntityPlayer
function AstroItems:IsStellar(player)
    return player:GetPlayerType() == AstroItems.Players.STELLAR or player:GetPlayerType() == AstroItems.Players.STELLAR_B
end

---@param star Entity
local function InitStar(star)
    local player = AstroItems:GetPlayerFromEntity(star)
    local sprite = star:GetSprite()

    star.Position = player.Position + Vector((math.random() - 0.5) * 60, ((math.random() - 0.5) * 60) - 34)
    star.SpriteScale = Vector.One * (math.random() + 0.5)
    star.SpriteRotation = math.random(0, 3) * 90
    star.FlipX = math.random() > 0.5
    star.Visible = true

    sprite:Play("Idle", true)
end

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:GetPlayerType() == AstroItems.Players.STELLAR then
                local star = Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EFFECT_STAR_VARIANT,
                    0,
                    player.Position,
                    Vector.Zero,
                    player
                )
                InitStar(star)

                AstroItems:ScheduleForUpdate(
                    function()
                        local star = Isaac.Spawn(
                            EntityType.ENTITY_EFFECT,
                            EFFECT_STAR_VARIANT,
                            0,
                            player.Position,
                            Vector.Zero,
                            player
                        )
                        InitStar(star)
                    end,
                    4
                )

                AstroItems:ScheduleForUpdate(
                    function()
                        local star = Isaac.Spawn(
                            EntityType.ENTITY_EFFECT,
                            EFFECT_STAR_VARIANT,
                            0,
                            player.Position,
                            Vector.Zero,
                            player
                        )
                        InitStar(star)
                    end,
                    8
                )

                AstroItems:ScheduleForUpdate(
                    function()
                        local star = Isaac.Spawn(
                            EntityType.ENTITY_EFFECT,
                            EFFECT_STAR_VARIANT,
                            0,
                            player.Position,
                            Vector.Zero,
                            player
                        )
                        InitStar(star)
                    end,
                    12
                )
            elseif player:GetPlayerType() == AstroItems.Players.STELLAR_B then
                Isaac.Spawn(
                    EntityType.ENTITY_EFFECT,
                    EFFECT_DUST_VARIANT,
                    0,
                    player.Position,
                    Vector.Zero,
                    player
                )
            end
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if effect:GetSprite():IsFinished("Idle") and effect.Visible then
            effect.Visible = false

            AstroItems:ScheduleForUpdate(
                function()
                    if effect:IsDead() then
                        return
                    end

                    InitStar(effect)
                end,
                math.random(0, 8)
            )
        end
    end,
    EFFECT_STAR_VARIANT
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local player = AstroItems:GetPlayerFromEntity(effect)

        effect.Position = player.Position + Vector(0, -34)
    end,
    EFFECT_DUST_VARIANT
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:GetPlayerType() == AstroItems.Players.LEAH_B then
            if not player:GetEffects():HasNullEffect(LEAH_B_HAIR) then
                player:GetEffects():AddNullEffect(LEAH_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(LEAH_B_HAIR) then
                player:GetEffects():RemoveNullEffect(LEAH_B_HAIR)
            end
        end

        if player:GetPlayerType() == AstroItems.Players.DIABELLSTAR then
            if not player:GetEffects():HasNullEffect(DIABELLSTAR_HAIR) then
                player:GetEffects():AddNullEffect(DIABELLSTAR_HAIR, true)
                -- hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        else
            if player:GetEffects():HasNullEffect(DIABELLSTAR_HAIR) then
                player:GetEffects():RemoveNullEffect(DIABELLSTAR_HAIR)
                -- hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        end

        if player:GetPlayerType() == AstroItems.Players.DIABELLSTAR_B then
            if not player:GetEffects():HasNullEffect(DIABELLSTAR_B_HAIR) then
                player:GetEffects():AddNullEffect(DIABELLSTAR_B_HAIR, true)
                -- hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        else
            if player:GetEffects():HasNullEffect(DIABELLSTAR_B_HAIR) then
                player:GetEffects():RemoveNullEffect(DIABELLSTAR_B_HAIR)
                -- hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        end

        if player:GetPlayerType() == AstroItems.Players.WATER_ENCHANTRESS then
            if not player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_HAIR) then
                player:GetEffects():AddNullEffect(WATER_ENCHANTRESS_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_HAIR) then
                player:GetEffects():RemoveNullEffect(WATER_ENCHANTRESS_HAIR)
            end
        end

        if player:GetPlayerType() == AstroItems.Players.WATER_ENCHANTRESS_B then
            if not player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_B_HAIR) then
                player:GetEffects():AddNullEffect(WATER_ENCHANTRESS_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_B_HAIR) then
                player:GetEffects():RemoveNullEffect(WATER_ENCHANTRESS_B_HAIR)
            end
        end

        if player:GetPlayerType() == AstroItems.Players.DAVID_MARTINEZ then
            if not player:GetEffects():HasNullEffect(DAVID_MARTINEZ_HAIR) then
                player:GetEffects():AddNullEffect(DAVID_MARTINEZ_HAIR, true)
                -- hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        else
            if player:GetEffects():HasNullEffect(DAVID_MARTINEZ_HAIR) then
                player:GetEffects():RemoveNullEffect(DAVID_MARTINEZ_HAIR)
                -- hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        end

        if player:GetPlayerType() == AstroItems.Players.DAVID_MARTINEZ_B then
            if not player:GetEffects():HasNullEffect(DAVID_MARTINEZ_B_HAIR) then
                player:GetEffects():AddNullEffect(DAVID_MARTINEZ_B_HAIR, true)
                -- hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        else
            if player:GetEffects():HasNullEffect(DAVID_MARTINEZ_B_HAIR) then
                player:GetEffects():RemoveNullEffect(DAVID_MARTINEZ_B_HAIR)
                -- hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SNAKE_EYE)
            end
        end

        if player:GetPlayerType() == AstroItems.Players.STELLAR then
            if not player:GetEffects():HasNullEffect(STELLAR_HAIR) then
                player:GetEffects():AddNullEffect(STELLAR_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(STELLAR_HAIR) then
                player:GetEffects():RemoveNullEffect(STELLAR_HAIR)
            end
        end

        if player:GetPlayerType() == AstroItems.Players.STELLAR_B then
            if not player:GetEffects():HasNullEffect(STELLAR_B_HAIR) then
                player:GetEffects():AddNullEffect(STELLAR_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(STELLAR_B_HAIR) then
                player:GetEffects():RemoveNullEffect(STELLAR_B_HAIR)
            end
        end
    end
)

AstroItems:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    CallbackPriority.LATE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:GetPlayerType() == AstroItems.Players.DIABELLSTAR then
            player.Damage = player.Damage * 1.2
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

-- AstroItems:AddCallback(
--     ModCallbacks.MC_POST_PLAYER_RENDER,
--     ---@param player EntityPlayer
--     ---@param offset Vector
--     function(_, player, offset)
--         if player:GetPlayerType() == AstroItems.Players.STELLAR_B then
--             sprite:Update()
--             sprite:Render(AstroItems:ToScreen(player.Position), Vector.Zero, Vector.Zero)
--         end
--     end
-- )

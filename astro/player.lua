-- local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Players = {
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
    AINZ_OOAL_GOWN = Isaac.GetPlayerTypeByName("Ainz Ooal Gown"),
    AINZ_OOAL_GOWN_B = Isaac.GetPlayerTypeByName("Tainted Ainz Ooal Gown", true),
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
local AINZ_OOAL_GOWN_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_ainz_ooal_gown_hair.anm2")
local AINZ_OOAL_GOWN_B_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_ainz_ooal_gownb_hair.anm2")

---@param player EntityPlayer
function Astro:IsLeah(player)
    return player:GetPlayerType() == Astro.Players.LEAH or player:GetPlayerType() == Astro.Players.LEAH_B
end

---@param player EntityPlayer
function Astro:IsDiabellstar(player)
    return player:GetPlayerType() == Astro.Players.DIABELLSTAR or player:GetPlayerType() == Astro.Players.DIABELLSTAR_B
end

---@param player EntityPlayer
function Astro:IsWaterEnchantress(player)
    return player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS or player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS_B
end

---@param player EntityPlayer
function Astro:IsDavidMartinez(player)
    return player:GetPlayerType() == Astro.Players.DAVID_MARTINEZ or player:GetPlayerType() == Astro.Players.DAVID_MARTINEZ_B
end

---@param player EntityPlayer
function Astro:IsStellar(player)
    return player:GetPlayerType() == Astro.Players.STELLAR or player:GetPlayerType() == Astro.Players.STELLAR_B
end

---@param player EntityPlayer
function Astro:IsAinzOoalGown(player)
    return player:GetPlayerType() == Astro.Players.AINZ_OOAL_GOWN or player:GetPlayerType() == Astro.Players.AINZ_OOAL_GOWN_B
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if player:GetPlayerType() == Astro.Players.LEAH_B then
            if not player:GetEffects():HasNullEffect(LEAH_B_HAIR) then
                player:GetEffects():AddNullEffect(LEAH_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(LEAH_B_HAIR) then
                player:GetEffects():RemoveNullEffect(LEAH_B_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.DIABELLSTAR then
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

        if player:GetPlayerType() == Astro.Players.DIABELLSTAR_B then
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

        if player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS then
            if not player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_HAIR) then
                player:GetEffects():AddNullEffect(WATER_ENCHANTRESS_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_HAIR) then
                player:GetEffects():RemoveNullEffect(WATER_ENCHANTRESS_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS_B then
            if not player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_B_HAIR) then
                player:GetEffects():AddNullEffect(WATER_ENCHANTRESS_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(WATER_ENCHANTRESS_B_HAIR) then
                player:GetEffects():RemoveNullEffect(WATER_ENCHANTRESS_B_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.DAVID_MARTINEZ then
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

        if player:GetPlayerType() == Astro.Players.DAVID_MARTINEZ_B then
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

        if player:GetPlayerType() == Astro.Players.STELLAR then
            if not player:GetEffects():HasNullEffect(STELLAR_HAIR) then
                player:GetEffects():AddNullEffect(STELLAR_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(STELLAR_HAIR) then
                player:GetEffects():RemoveNullEffect(STELLAR_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.STELLAR_B then
            if not player:GetEffects():HasNullEffect(STELLAR_B_HAIR) then
                player:GetEffects():AddNullEffect(STELLAR_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(STELLAR_B_HAIR) then
                player:GetEffects():RemoveNullEffect(STELLAR_B_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.AINZ_OOAL_GOWN then
            if not player:GetEffects():HasNullEffect(AINZ_OOAL_GOWN_HAIR) then
                player:GetEffects():AddNullEffect(AINZ_OOAL_GOWN_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(AINZ_OOAL_GOWN_HAIR) then
                player:GetEffects():RemoveNullEffect(AINZ_OOAL_GOWN_HAIR)
            end
        end

        if player:GetPlayerType() == Astro.Players.AINZ_OOAL_GOWN_B then
            if not player:GetEffects():HasNullEffect(AINZ_OOAL_GOWN_B_HAIR) then
                player:GetEffects():AddNullEffect(AINZ_OOAL_GOWN_B_HAIR, true)
            end
        else
            if player:GetEffects():HasNullEffect(AINZ_OOAL_GOWN_B_HAIR) then
                player:GetEffects():RemoveNullEffect(AINZ_OOAL_GOWN_B_HAIR)
            end
        end
    end
)

Astro:AddPriorityCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    CallbackPriority.LATE,
    ---@param player EntityPlayer
    ---@param cacheFlag CacheFlag
    function(_, player, cacheFlag)
        if player:GetPlayerType() == Astro.Players.DIABELLSTAR then
            player.Damage = player.Damage * 1.2
        end
    end,
    CacheFlag.CACHE_DAMAGE
)

-- Astro:AddCallback(
--     ModCallbacks.MC_POST_PLAYER_RENDER,
--     ---@param player EntityPlayer
--     ---@param offset Vector
--     function(_, player, offset)
--         if player:GetPlayerType() == Astro.Players.STELLAR_B then
--             sprite:Update()
--             sprite:Render(Astro:ToScreen(player.Position), Vector.Zero, Vector.Zero)
--         end
--     end
-- )

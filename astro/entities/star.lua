local isc = require("astro.lib.isaacscript-common")

local EFFECT_STAR_VARIANT = Isaac.GetEntityVariantByName("Effect Star");

---@param player EntityPlayer
local function CheckEnable(player)
    return player:GetPlayerType() == Astro.Players.STELLAR or player:HasCollectible(Astro.Collectible.ALBIREO)
end

---@param star Entity
local function InitStar(star)
    local player = Astro:GetPlayerFromEntity(star)
    local sprite = star:GetSprite()

    star.Position = player.Position + Vector((math.random() - 0.5) * 60, ((math.random() - 0.5) * 60) - 34)
    star.SpriteScale = Vector.One * (math.random() + 0.5)
    star.SpriteRotation = math.random(0, 3) * 90
    star.FlipX = math.random() > 0.5
    star.Visible = true

    sprite:Play("Idle", true)
end


local function SpawnStars(player)
    if CheckEnable(player) then
        local star = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EFFECT_STAR_VARIANT,
            0,
            player.Position,
            Vector.Zero,
            player
        )
        InitStar(star)

        Astro:ScheduleForUpdate(
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

        Astro:ScheduleForUpdate(
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

        Astro:ScheduleForUpdate(
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
    end
end

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            SpawnStars(player)
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        if effect:GetSprite():IsFinished("Idle") and effect.Visible then
            effect.Visible = false

            Astro:ScheduleForUpdate(
                function()
                    if effect:IsDead() then
                        return
                    end

                    local player = Astro:GetPlayerFromEntity(effect)

                    if player and CheckEnable(player) then
                        InitStar(effect)
                        return
                    end
                    
                    effect:Die()
                end,
                math.random(0, 8)
            )
        end
    end,
    EFFECT_STAR_VARIANT
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if collectibleType == Astro.Collectible.ALBIREO and Isaac.FindByType(EntityType.ENTITY_EFFECT, EFFECT_STAR_VARIANT, 0)[1] == nil then
            SpawnStars(player)
        end
    end
)

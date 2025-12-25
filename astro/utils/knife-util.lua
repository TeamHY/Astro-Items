Astro.KnifeUtil = {}

Astro.KnifeUtil.KNIFE_SWING_ANIMS = {
	"Swing",
    "Swing2",
    "SwingDown",
    "SwingDown2",
    "AttackRight",
    "AttackLeft",
    "AttackUp",
    "AttackDown",
    "SpinRight",
    "SpinLeft",
    "SpinUp",
    "SpinDown"
}

-- done with trial and error by yours truly (catinsurance)
Astro.KnifeUtil.KNIFE_VARIANT_TO_ATTACK_DISTANCE = {
    [1] = 15, -- bone club
    [2] = 40, -- bone knife
    [3] = 20, -- donkey jawbone/berserk club
    [4] = 15, -- bag of crafting
    [9] = 15, -- notched axe
    [10] = 20, -- spirit sword
    [11] = 20, -- tech sword
}

Astro.KnifeUtil.KNIFE_HITBOX_VARIANT = 3113
Astro.KnifeUtil.ATTACK_RADIUS = 45
Astro.KnifeUtil.SPIN_RADIUS = 80

---Checks if the player has a knife that can be swung, like Spirit Sword
---@param player EntityPlayer
---@return boolean isSwingable
function Astro.KnifeUtil:HasSwingableKnife(player)
    local weapon = player:GetActiveWeaponEntity()
    weapon = weapon and weapon:ToKnife()
    if weapon then
        if Astro.KnifeUtil.KNIFE_VARIANT_TO_ATTACK_DISTANCE[weapon.Variant] then
            return true
        end
    end

    return false
end

---Returns the player's active knife, or nil if they don't have one.
---@param player EntityPlayer
---@return EntityKnife? knife
function Astro.KnifeUtil:GetKnife(player)
    local weapon = player:GetActiveWeaponEntity()
    return weapon:ToKnife()
end

---Gets the offset from the knife that the swing hitbox will be around.
---@param knifeOrVariant EntityKnife | integer The knife, or the knife variant.
---@return number? offset Nil if the knife cannot be swung.
function Astro.KnifeUtil:GetSwingOffsetForVariant(knifeOrVariant)
    return Astro.KnifeUtil.KNIFE_VARIANT_TO_ATTACK_DISTANCE[type(knifeOrVariant) == "number" and knifeOrVariant or knifeOrVariant.Variant]
end

---Gets a general position of where the swing hitbox is for a swinging knife.
---@param knife EntityKnife The knife to base the position off of,
---@param setOffset number? A number to use for the offset, or nil for rotation to be handled for you. Also handles spirit sword.
---@return Vector position
function Astro.KnifeUtil:GetSwingPosition(knife, setOffset)
    local sprite = knife:GetSprite()
    if not setOffset and sprite:GetAnimation():match("Spin") then
        local frame = Astro:Clamp(sprite:GetFrame(), 3, 12) - 3
        return knife.Position + Vector.FromAngle(frame * 40) * (setOffset or Astro.KnifeUtil:GetSwingOffsetForVariant(knife))
    end

    return knife.Position + Vector.FromAngle(knife.Rotation) * (setOffset or Astro.KnifeUtil:GetSwingOffsetForVariant(knife))
end

---If the player is swinging a knife, get all entities in general radius of the hitbox.
---If there are no knives or the player has no active knife, this returns an empty table.
---@param player EntityPlayer
---@param setKnife EntityKnife An optional knife to use instead of the player's active knife.
---@return Entity[]
function Astro.KnifeUtil:GetEntitiesInSwing(player, setKnife)
    local knife = setKnife or (player:GetActiveWeaponEntity() and player:GetActiveWeaponEntity():ToKnife())
    if knife then
        local position = Astro.KnifeUtil:GetSwingPosition(knife)

        if knife:GetSprite():GetAnimation():match("Spin") then
            return Isaac.FindInRadius(player.Position, Astro.KnifeUtil.SPIN_RADIUS)
        else
            return Isaac.FindInRadius(position, Astro.KnifeUtil.ATTACK_RADIUS)
        end
    end

    return {}
end

---Returns true if the player's knife is in a swing animation, false otherwise.
---@param playerOrKnife EntityPlayer | EntityKnife Provide a player to get the player's active knife entity. If there is none, this will return false.
---@return boolean swinging
function Astro.KnifeUtil:IsSwingingKnife(playerOrKnife)
    if playerOrKnife:ToPlayer() then
        local weapon = playerOrKnife:GetActiveWeaponEntity()
        local knife = weapon and weapon:ToKnife()
        if knife then
            local sprite = knife:GetSprite()
            for _, anim in ipairs(Astro.KnifeUtil.KNIFE_SWING_ANIMS) do
                if sprite:IsPlaying(anim) and knife.SubType == 4 then -- 4 is the subtype for the club hitbox
                    return true
                end
            end

            if sprite:GetAnimation():match("Spin") then
                return true
            end
        end
    else
        local sprite = playerOrKnife:GetSprite()
        for _, anim in ipairs(Astro.KnifeUtil.KNIFE_SWING_ANIMS) do
            if sprite:IsPlaying(anim) and playerOrKnife.SubType == 4 then -- 4 is the subtype for the club hitbox
                return true
            end
        end

        if sprite:GetAnimation():match("Spin") then
            return true
        end
    end

    return false
end

---@param player EntityPlayer
---@param angle Number
---@param damageInfo { Damage: number, Radius: number?, Flags: DamageFlag? }
---@param spritesheet { Main: string?, Whoosh: string? }
function Astro.KnifeUtil:SpawnSwingEffect(player, angle, damageInfo, spritesheet)
    variant = variant or Astro.KnifeUtil.KNIFE_HITBOX_VARIANT

    local hitbox = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, 0, player.Position, Vector.Zero, player):ToEffect()
    hitbox.SpriteOffset = Vector(0, -10)
    hitbox:FollowParent(player)

    local hData = hitbox:GetData()
    hData._ASTRO_knifeUtilAngle = angle

    local swingDir = Vector.FromAngle(angle) * 9
    local radius = damageInfo.Radius or Astro.KnifeUtil.ATTACK_RADIUS
    
    local entities = Isaac.FindInRadius(hitbox.Position + swingDir, radius, EntityPartition.ENEMY | EntityPartition.PICKUP)
    if #entities > 0 then
        local sfx = SFXManager()
        local flags = damageInfo.Flags or 0
        
        for i, ent in ipairs(entities) do
            local dirVec = ent.Position - player.Position
            dirVec = dirVec:Normalized()
            ent.Velocity = dirVec * 6

            local pickup = ent:ToPickup()
            if pickup then
                if
                    REPENTOGON
                    and pickup.Variant < PickupVariant.PICKUP_TROPHY
                    and pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE
                    and pickup.Variant ~= PickupVariant.PICKUP_BIGCHEST
                    and not pickup:IsShopItem()
                then
                    player:ForceCollide(pickup, false)
                end
            else
                ent:TakeDamage(damageInfo.Damage, flags, EntityRef(player), 30)
                sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
            end
        end
    end

    local sprite = hitbox:GetSprite()
    local newSheet0 = "gfx/ui/death portraits extra.png"
    local newSheet1 = nil
    if spritesheet then
        if spritesheet.Main then
            newSheet0 = spritesheet.Main
        end
        if spritesheet.Whoosh then
            newSheet1 = spritesheet.Whoosh
            sprite:ReplaceSpritesheet(1, newSheet1)
        end
    end
    sprite:ReplaceSpritesheet(0, newSheet0)
    sprite:LoadGraphics()
    sprite:Play("Swing", true)

    return hitbox
end

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        effect.SpriteOffset = Vector(0, -10)
        
        local hData = effect:GetData()
        local angle = hData._ASTRO_knifeUtilAngle % 360
        if angle < 0 then
            angle = angle + 360
        end
        local snappedAngle = math.floor((angle / 90) + 0.5) * 90
        
        local sprite = effect:GetSprite()
        sprite.Rotation = snappedAngle - 90

        if sprite:IsFinished("Swing") then
            effect:Remove()
        end
    end,
    Astro.KnifeUtil.KNIFE_HITBOX_VARIANT
)
AstroItems.KnifeUtil = {}

AstroItems.KnifeUtil.KNIFE_SWING_ANIMS = {
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
AstroItems.KnifeUtil.KNIFE_VARIANT_TO_ATTACK_DISTANCE = {
    [1] = 15, -- bone club
    [2] = 40, -- bone knife
    [3] = 20, -- donkey jawbone/berserk club
    [4] = 15, -- bag of crafting
    [9] = 15, -- notched axe
    [10] = 20, -- spirit sword
    [11] = 20, -- tech sword
}

AstroItems.KnifeUtil.ATTACK_RADIUS = 45
AstroItems.KnifeUtil.SPIN_RADIUS = 80

---Checks if the player has a knife that can be swung, like Spirit Sword
---@param player EntityPlayer
---@return boolean isSwingable
function AstroItems.KnifeUtil:HasSwingableKnife(player)
    local weapon = player:GetActiveWeaponEntity()
    weapon = weapon and weapon:ToKnife()
    if weapon then
        if AstroItems.KnifeUtil.KNIFE_VARIANT_TO_ATTACK_DISTANCE[weapon.Variant] then
            return true
        end
    end

    return false
end

---Returns the player's active knife, or nil if they don't have one.
---@param player EntityPlayer
---@return EntityKnife? knife
function AstroItems.KnifeUtil:GetKnife(player)
    local weapon = player:GetActiveWeaponEntity()
    return weapon:ToKnife()
end

---Gets the offset from the knife that the swing hitbox will be around.
---@param knifeOrVariant EntityKnife | integer The knife, or the knife variant.
---@return number? offset Nil if the knife cannot be swung.
function AstroItems.KnifeUtil:GetSwingOffsetForVariant(knifeOrVariant)
    return AstroItems.KnifeUtil.KNIFE_VARIANT_TO_ATTACK_DISTANCE[type(knifeOrVariant) == "number" and knifeOrVariant or knifeOrVariant.Variant]
end

---Gets a general position of where the swing hitbox is for a swinging knife.
---@param knife EntityKnife The knife to base the position off of,
---@param setOffset number? A number to use for the offset, or nil for rotation to be handled for you. Also handles spirit sword.
---@return Vector position
function AstroItems.KnifeUtil:GetSwingPosition(knife, setOffset)
    local sprite = knife:GetSprite()
    if not setOffset and sprite:GetAnimation():match("Spin") then
        local frame = AstroItems:Clamp(sprite:GetFrame(), 3, 12) - 3
        return knife.Position + Vector.FromAngle(frame * 40) * (setOffset or AstroItems.KnifeUtil:GetSwingOffsetForVariant(knife))
    end

    return knife.Position + Vector.FromAngle(knife.Rotation) * (setOffset or AstroItems.KnifeUtil:GetSwingOffsetForVariant(knife))
end

---If the player is swinging a knife, get all entities in general radius of the hitbox.
---If there are no knives or the player has no active knife, this returns an empty table.
---@param player EntityPlayer
---@param setKnife EntityKnife An optional knife to use instead of the player's active knife.
---@return Entity[]
function AstroItems.KnifeUtil:GetEntitiesInSwing(player, setKnife)
    local knife = setKnife or (player:GetActiveWeaponEntity() and player:GetActiveWeaponEntity():ToKnife())
    if knife then
        local position = AstroItems.KnifeUtil:GetSwingPosition(knife)

        if knife:GetSprite():GetAnimation():match("Spin") then
            return Isaac.FindInRadius(player.Position, AstroItems.KnifeUtil.SPIN_RADIUS)
        else
            return Isaac.FindInRadius(position, AstroItems.KnifeUtil.ATTACK_RADIUS)
        end
    end

    return {}
end

---Returns true if the player's knife is in a swing animation, false otherwise.
---@param playerOrKnife EntityPlayer | EntityKnife Provide a player to get the player's active knife entity. If there is none, this will return false.
---@return boolean swinging
function AstroItems.KnifeUtil:IsSwingingKnife(playerOrKnife)
    if playerOrKnife:ToPlayer() then
        local weapon = playerOrKnife:GetActiveWeaponEntity()
        local knife = weapon and weapon:ToKnife()
        if knife then
            local sprite = knife:GetSprite()
            for _, anim in ipairs(AstroItems.KnifeUtil.KNIFE_SWING_ANIMS) do
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
        for _, anim in ipairs(AstroItems.KnifeUtil.KNIFE_SWING_ANIMS) do
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

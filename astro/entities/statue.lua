local STATUE_VARIANT = Isaac.GetEntityVariantByName("Sloth Statue")

Astro.Entity.SLOTH_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 0,
}

Astro.Entity.LUST_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 1,
}

Astro.Entity.GLUTTONY_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 2,
}

Astro.Entity.PRIDE_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 3,
}

Astro.Entity.WRATH_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 4,
}

Astro.Entity.ENVY_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 5,
}

Astro.Entity.GREED_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 6,
}

Astro.Entity.GREEDIER_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 7,
}

Astro.Entity.TREASURE_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 8,
}

Astro.Entity.PLANETARIUM_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 9,
}

Astro.Entity.DUALITY_STATUE = {
    Type = EntityType.ENTITY_EFFECT,
    Variant = STATUE_VARIANT,
    SubType = 10,
}

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    function(_, effect)
        local players = Isaac.FindInRadius(effect.Position, 20, EntityPartition.PLAYER)

        for _, player in ipairs(players) do
            local dirVec = player.Position - effect.Position
            dirVec = dirVec:Normalized()
            player:AddVelocity(dirVec * 1.5)
        end
    end,
    STATUE_VARIANT
)

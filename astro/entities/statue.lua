local StatueType = Isaac.GetEntityTypeByName("Sloth Statue")
local StatueVariant = Isaac.GetEntityVariantByName("Sloth Statue")

Astro.Entity.SLOTH_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 0,
}

Astro.Entity.LUST_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 1,
}

Astro.Entity.GLUTTONY_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 2,
}

Astro.Entity.PRIDE_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 3,
}

Astro.Entity.WRATH_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 4,
}

Astro.Entity.ENVY_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 5,
}

Astro.Entity.GREED_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 6,
}

Astro.Entity.GREEDIER_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 7,
}

Astro.Entity.TREASURE_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 8,
}

Astro.Entity.PLANETARIUM_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 9,
}

Astro.Entity.DUALITY_STATUE = {
    Type = StatueType,
    Variant = StatueVariant,
    SubType = 10,
}

Astro:AddCallback(
    ModCallbacks.MC_POST_NPC_INIT,
    ---@param npc EntityNPC
    function(_, npc)
        if npc.Variant == StatueVariant and npc.Type == StatueType then
            npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:GetData()["Astro_InitPosition"] = npc.Position
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_NPC_UPDATE,
    ---@param npc EntityNPC
    function(_, npc)
        if npc.Variant == StatueVariant and npc.Type == StatueType then
            npc.Position = npc:GetData()["Astro_InitPosition"]
            npc.FlipX = false
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function()
        local level = Game():GetLevel()
        local room = Game():GetRoom()
        local roomDesc = level:GetCurrentRoomDesc()
        local roomType = roomDesc.Data.Type
        local roomSubType = roomDesc.Data.Subtype
        local centerPos = room:GetCenterPos()

        if roomType == RoomType.ROOM_MINIBOSS then
            if roomSubType == 0 or roomSubType == 7 then
                Astro:SpawnEntity(Astro.Entity.SLOTH_STATUE, centerPos)
            elseif roomSubType == 1 or roomSubType == 8 then
                Astro:SpawnEntity(Astro.Entity.LUST_STATUE, centerPos)
            elseif roomSubType == 2 or roomSubType == 9 then
                Astro:SpawnEntity(Astro.Entity.WRATH_STATUE, centerPos)
            elseif roomSubType == 3 or roomSubType == 10 then
                Astro:SpawnEntity(Astro.Entity.GLUTTONY_STATUE, centerPos)
            elseif roomSubType == 4 or roomSubType == 11 then
                -- 그리드 동상은 금고방에 생성
                -- Astro:SpawnEntity(Astro.Entity.GREED_STATUE, centerPos)
            elseif roomSubType == 5 or roomSubType == 12 then
                Astro:SpawnEntity(Astro.Entity.ENVY_STATUE, centerPos)
            elseif roomSubType == 6 or roomSubType == 13 or roomSubType == 14 then -- Ultra Pride도 일단 포함
                Astro:SpawnEntity(Astro.Entity.PRIDE_STATUE, centerPos)
            end
        elseif roomType == RoomType.ROOM_CHEST then
            Astro:SpawnEntity(Astro.Entity.GREED_STATUE, centerPos)
        elseif roomType == RoomType.ROOM_SHOP then
            Astro:SpawnEntity(Astro.Entity.GREEDIER_STATUE, centerPos)
        elseif roomType == RoomType.ROOM_TREASURE then
            Astro:SpawnEntity(Astro.Entity.TREASURE_STATUE, centerPos)
        elseif roomType == RoomType.ROOM_PLANETARIUM then
            Astro:SpawnEntity(Astro.Entity.PLANETARIUM_STATUE, centerPos)
        end
    end
)

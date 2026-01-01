Astro.Collectible.PLUNGER = Isaac.GetItemIdByName("Plunger")

---

local PLUNGER_DIP = 4
local PLUNGER_DMG = 40

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.PLUNGER,
                "뚫어뻥",
                "미야옹!",
                "사용 시 랜덤한 Dip 패밀리어 " .. PLUNGER_DIP .. "마리를 소환합니다." ..
                "#{{Poop}} 똥 타입 적과 보스에게 사용 시 40의 피해를 줍니다." ..
                "#Clog 보스에게 사용 시 보스를 즉사시킵니다."
            )
            EID:addCarBatteryCondition(Astro.Collectible.PLUNGER, nil, PLUNGER_DIP, nil, "ko_kr")
            EID:addCarBatteryCondition(Astro.Collectible.PLUNGER, nil, 40, nil, "ko_kr")
            ----
            Astro.EID:AddCollectible(
                Astro.Collectible.PLUNGER,
                "Plunger",
                "",
                "Spawns " .. PLUNGER_DIP .. " random Dip familiars" ..
                "#{{Poop}} Deals 40 damage when used against Poop-type enemies and bosses" ..
                "#Kills Clog instantly",
                nil, "en_us"
            )
            EID:addCarBatteryCondition(Astro.Collectible.PLUNGER, nil, PLUNGER_DIP, nil, "en_us")
            EID:addCarBatteryCondition(Astro.Collectible.PLUNGER, nil, 40, nil, "en_us")
        end
    end
)

local poopMonsters = {
    EntityType.ENTITY_DINGA,
    EntityType.ENTITY_DIP,
    EntityType.ENTITY_DRIP,
    EntityType.ENTITY_SQUIRT,
    EntityType.ENTITY_SPLURT,
    EntityType.ENTITY_HARDY,
    EntityType.ENTITY_DINGLE,
    EntityType.ENTITY_COLOSTOMIA,
    EntityType.ENTITY_TURDLET,
    EntityType.ENTITY_BROWNIE
}

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local dmg = PLUNGER_DMG
        local spawnedAmount = PLUNGER_DIP
        if playerWhoUsedItem:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
            dmg = PLUNGER_DMG * 2
            spawnedAmount = PLUNGER_DIP * 2
        end

        for _, entType in pairs(poopMonsters) do
            local entities = Isaac.FindByType(entType)
            if #entities > 0 then
                for i, ent in pairs(entities) do
                    ent:TakeDamage(dmg, 0, EntityRef(playerWhoUsedItem), 0)
                end
            end
        end

        local clogs = Isaac.FindByType(EntityType.ENTITY_CLOG)
        if #clogs > 0 then
            for j, clog in ipairs(clogs) do
                clog:Kill()
            end
        end
        
        local rng = playerWhoUsedItem:GetCollectibleRNG(collectibleID)
        for k = 1, spawnedAmount do
            local randomSubType = rng:RandomInt(8)
            Isaac.Spawn(3, 201, randomSubType, playerWhoUsedItem.Position, Vector(0,0), playerWhoUsedItem)
        end
        
        local sfx = SFXManager()
        if SoundEffect.SOUND_ITEM_RAISE and sfx:IsPlaying(SoundEffect.SOUND_ITEM_RAISE) then
            sfx:Stop(SoundEffect.SOUND_ITEM_RAISE)
        end
        SFXManager():Play(SoundEffect.SOUND_SINK_DRAIN_GURGLE)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.PLUNGER
)

Astro.Collectible.ANGELIC_D6 = Isaac.GetItemIdByName("Angelic D6")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.ANGELIC_D6,
                "천사빛 주사위",
                "축복을 굴려라",
                "{{AngelRoom}} 사용 시 그 방의 아이템을 천사방 아이템으로 바꿉니다." ..
                "모드로 추가된 아이템은 포함하지 않습니다."
            )

            Astro.EID:AddCollectible(
                Astro.Collectible.ANGELIC_D6,
                "Angelic D6", "",
                "{{AngelRoom}} Rerolls pedestal items in the room into Angel items" ..
                "Items added via mods are not included",
                nil, "en_us"
            )
        end
    end
)

local ANGELIC_ITEMS = {
    7,   -- Blood of the Martyr
    33,  -- The Bible
    72,  -- Rosary
    78,  -- Book of Revelations
    98,  -- The Relic
    101, -- The Halo
    108, -- The Wafer
    112, -- Guardian Angel
    124, -- Dead Sea Scrolls
    138, -- Stigmata
    142, -- Scapular
    146, -- Prayer Card
    156, -- Habit
    162, -- Celtic Cross
    173, -- Mitre
    178, -- Holy Water
    182, -- Sacred Heart
    184, -- Holy Grail
    185, -- Dead Dove
    197, -- Jesus Juice
    243, -- Trinity Shield
    313, -- Holy Mantle
    326, -- Breath of Life
    331, -- Godhead
    332, -- Lazarus' Rags
    333, -- The Mind
    334, -- The Body
    335, -- The Soul
    363, -- Sworn Protector
    374, -- Holy Light
    387, -- Censer
    390, -- Seraphim
    400, -- Spear Of Destiny
    407, -- Purity
    413, -- Immaculate Conception
    415, -- Crown Of Light
    423, -- Circle of Protection
    464, -- Glyph of Balance
    477, -- Void
    490, -- Eden's Soul
    498, -- Duality
    499, -- Eucharist
    510, -- Delirious
    519, -- Lil Delirium
    526, -- 7 Seals
    528, -- Angelic Prism
    533, -- Trisagion
    543, -- Hallowed Ground
    567, -- Paschal Candle
    568, -- Divine Intervention
    573, -- Immaculate Heart
    574, -- Monstrance
    579, -- Spirit Sword
    584, -- Book of Virtues
    586, -- The Stairway
    601, -- Act of Contrition
    622, -- Genesis
    634, -- Purgatory
    640, -- Urn of Souls
    643, -- Revelation
    651, -- Star of Bethlehem
    653, -- Vade Retro
    685, -- Jar of Wisps
    686, -- Soul Locket
    691, -- Sacred Orb
    696, -- Salvation
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
        local entities = Isaac.GetRoomEntities()

        for _, entity in ipairs(entities) do
            if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType ~= 0 then
                local item = ANGELIC_ITEMS[rngObj:RandomInt(#ANGELIC_ITEMS) + 1]

                entity:ToPickup():Morph(entity.Type, entity.Variant, item, true)
                Game():SpawnParticles(entity.Position, EffectVariant.POOF01, 1, 0)
                SFXManager():Play(SoundEffect.SOUND_SUPERHOLY)
            end
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.ANGELIC_D6
)

Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL = Isaac.GetItemIdByName("The Holy Blood and the Holy Grail")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL,
        "성혈과 성배", "피 묻은 성녀, 막달레나의 잔",
        "사용 시 {{TreasureRoom}}보물방, {{AngelRoom}}천사방, {{SecretRoom}}비밀방 아이템을 각각 하나씩 소환합니다." ..
        "#{{ArrowGrayRight}} 소환된 아이템 중 하나를 선택하면 나머지는 사라집니다.")
end

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local itemPool = Game():GetItemPool()
        local currentRoom = Game():GetLevel():GetCurrentRoom()

        Astro:SpawnCollectible(itemPool:GetCollectible(ItemPoolType.POOL_TREASURE, true, currentRoom:GetSpawnSeed()), playerWhoUsedItem.Position, Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL)
        Astro:SpawnCollectible(itemPool:GetCollectible(ItemPoolType.POOL_ANGEL, true, currentRoom:GetSpawnSeed()), playerWhoUsedItem.Position, Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL)
        Astro:SpawnCollectible(itemPool:GetCollectible(ItemPoolType.POOL_SECRET, true, currentRoom:GetSpawnSeed()), playerWhoUsedItem.Position, Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL)

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.THE_HOLY_BLOOD_AND_THE_HOLY_GRAIL
)

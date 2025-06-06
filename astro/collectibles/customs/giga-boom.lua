---

local SPAWN_COUNT = 10

---

Astro.Collectible.GIGA_BOOM = Isaac.GetItemIdByName("Giga Boom")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.GIGA_BOOM,
        "기가 붐",
        "...",
        "최초 획득 시 기가 폭탄 10개를 소환합니다."
    )
end

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Astro:IsFirstAdded(Astro.Collectible.GIGA_BOOM) then
            for i = 1, SPAWN_COUNT do
                local angle = i * 360 / SPAWN_COUNT
                local offset = Vector(math.cos(math.rad(angle)) * 80, math.sin(math.rad(angle)) * 80)

                Astro:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 7, player.Position + offset)
            end
        end
    end,
    Astro.Collectible.GIGA_BOOM
)

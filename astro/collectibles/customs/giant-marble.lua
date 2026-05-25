---

local TRINKET_COUNT = 3

---

Astro.Collectible.GIANT_MARBLE = Isaac.GetItemIdByName("Giant Marble")
local ITEM_ID = Astro.Collectible.GIANT_MARBLE

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "거대 구슬",
                "...",
                "{{Trinket}} 획득 시 랜덤 장신구 " .. TRINKET_COUNT .. "개와 {{Pill1}}메가 Gulp! 알약을 소환합니다."
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Giant Marble",
                "...",
                "{{Trinket}} Spawns " .. TRINKET_COUNT .. " random trinkets and a {{Pill1}}Mega Gulp! pill on pickup",
                "en_us"
            )
        end
    end
)

local function SpawnMegaGulpPill(position)
    local itemPool = Game():GetItemPool()
    local pillColor = itemPool:ForceAddPillEffect(PillEffect.PILLEFFECT_GULP)

    return Astro:Spawn(
        EntityType.ENTITY_PICKUP,
        PickupVariant.PICKUP_PILL,
        pillColor | PillColor.PILL_GIANT_FLAG,
        position
    ):ToPickup()
end

local function SpawnRandomTrinkets(position, count)
    local itemPool = Game():GetItemPool()

    for _ = 1, count do
        Astro:SpawnTrinket(itemPool:GetTrinket(), Isaac.GetFreeNearPosition(position, 40))
    end
end

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    function(_, player)
        if Astro:IsFirstAdded(ITEM_ID) then
            SpawnRandomTrinkets(player.Position, TRINKET_COUNT)
            SpawnMegaGulpPill(Isaac.GetFreeNearPosition(player.Position, 40))
        end
    end,
    ITEM_ID
)

---

Astro.Collectible.MAYUSHIIS_POCKET_WATCH = Isaac.GetItemIdByName("Mayushii's Pocket Watch")

local ITEM_ID = Astro.Collectible.MAYUSHIIS_POCKET_WATCH

local BASE_CHANCE = 0.5

local LUCK_CHANCE = 0.01

---

if EID then
    Astro:AddEIDCollectible(
        ITEM_ID,
        "마유시의 회중시계",
        "...",
        "페널티 피격 시 50% 확률로 {{Collectible422}}Glowing Hourglass가 발동됩니다." ..
        "#{{Blank}} {{ColorGray}}(클리어한 방과 {{BossRoom}}보스방에서는 미발동){{CR}}" ..
        "#중첩 시 최종 확률이 합 연산으로 증가합니다." ..
        "#{{LuckSmall}} 행운 50 이상일 때 100% 확률 (행운 1당 +1%p)"
    )

    Astro:AddEIDCollectible(
        ITEM_ID,
        "Mayushii's Pocket Watch",
        "",
        "50% chance to trigger {{Collectible422}}Glowing Hourglass when taking penalty damage. Does not activate in cleared rooms or {{BossRoom}}boss rooms." ..
        "#Stacking increases the final chance by additive calculation." ..
        "#{{Luck}} 100% chance at 50 luck (+1%p per luck)",
        nil,
        "en_us"
    )
end

Astro:AddCallback(
    ModCallbacks.MC_USE_CARD,
    ---@param cardID Card
    ---@param player EntityPlayer
    ---@param useFlags UseFlag
    function(_, cardID, player, useFlags)
        local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

        for _, collectible in ipairs(collectibles) do
            if collectible.SubType == CollectibleType.COLLECTIBLE_STOP_WATCH or collectible.SubType == CollectibleType.COLLECTIBLE_BROKEN_WATCH then
                local pickup = collectible:ToPickup() ---@cast pickup EntityPickup
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)

                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, pickup.Position, pickup.Velocity, player)
                SFXManager():Play(Astro.SoundEffect.MAYUSHIIS_POCKET_WATCH_APPEAR)
            end
        end
    end,
    Card.RUNE_HAGALAZ
)

---@param player EntityPlayer
local function TryEffect(player)
    local room = Game():GetRoom()
    
    if room:IsClear() then
        return
    end
    
    if room:GetType() == RoomType.ROOM_BOSS then
        return
    end

    local data = Astro.SaveManager.GetRunSave(player, true)

    if not data["mayushiisPocketWatchRNG"] then
        data["mayushiisPocketWatchRNG"] = Astro:CopyRNG(player:GetCollectibleRNG(ITEM_ID))
    end

    local rng = data["mayushiisPocketWatchRNG"]
    local itemCount = player:GetCollectibleNum(ITEM_ID)
    
    if rng:RandomFloat() < (BASE_CHANCE + player.Luck * LUCK_CHANCE) * itemCount then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    end
end

Astro:AddCallback(
    Astro.Callbacks.POST_PLAYER_TAKE_PENALTY,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(ITEM_ID) then
            return
        end

        TryEffect(player)
    end
)

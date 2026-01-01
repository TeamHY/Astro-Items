---

Astro.Collectible.BLOOD_GUPPY = Isaac.GetItemIdByName("Blood Guppy")

local ITEM_ID = Astro.Collectible.BLOOD_GUPPY

local BASE_FLY_CHANCE = 0.5
local LUCK_FLY_CHANCE = 0.01

local COOLDOWN_TIME = 15

---

local FLY_SUBTYPE = 1001
local FLY_COLOR = Color(1, 1, 1, 1, 1, 0, 0)

if EID then
    Astro.EID:AddCollectible(    -- `혈사 구피`는 틀린 명칭입니다. 컨셉이 유황이면 영어명을 `Brimstone Guppy`, 한국어명을 `유황 구피` 또는 `유황불 구피`로 바꿔주세요.
        ITEM_ID,                                               -- 컨셉이 혈액이면 한국어명을 `핏빛 구피`/`핏덩이 구피`/`피투성이 구피`로 바꿔주세요
        "혈사 구피",
        "...",
        "파란 파리가 소환될 때 50% 확률로 혈사 파리를 추가로 소환합니다." ..
        "#{{ArrowGrayRight}} 혈사 파리는 적에게 접촉시 해당 위치에 {{Collectible118}}Brimstone 혈사포가 소환됩니다." ..
        "#{{LuckSmall}} 행운 50 이상일 때 100% 확률 (행운 1당 +1%p)"
    )

    Astro.EID:AddCollectible(
        ITEM_ID,
        "Blood Guppy",
        "",
        "50% chance to spawn an additional blood fly." ..
        "#Blood flies spawn {{Collectible118}}Brimstone laser at monster location when dealing damage." ..
        "#{{Luck}} 100% chance at 50 luck (+1%p per luck)",
        nil,
        "en_us"
    )
end

Astro:AddUpgradeAction(
    function(player)
        if player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) and player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
            local guppyItems = Astro:FindGuppyItems(player)
            
            if #guppyItems > 0 then
                return {
                    guppyItems = guppyItems
                }
            end
        end

        return nil
    end,
    function(player, data)
        for _, guppyItem in ipairs(data.guppyItems) do
            guppyItem:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, guppyItem.Position, guppyItem.Velocity, nil)
        end
    end
)

Astro:AddCallback(
    Astro.Callbacks.SPAWNED_BLUE_FLY,
    ---@param fly EntityFamiliar
    function(_, fly)
        local player = fly.Player

        if not player:HasCollectible(ITEM_ID) then
            return
        end

        local frameCount = Game():GetFrameCount()
        local data = Astro.SaveManager.GetRunSave(player)
        local rng = player:GetCollectibleRNG(ITEM_ID)
        local flyChance = BASE_FLY_CHANCE + (player.Luck * LUCK_FLY_CHANCE)

        if (data["bloodGuppyCooldown"] == nil or data["bloodGuppyCooldown"] < frameCount) and rng:RandomFloat() < flyChance then
            local newFly = Isaac.Spawn(
                EntityType.ENTITY_FAMILIAR,
                FamiliarVariant.BLUE_FLY,
                FLY_SUBTYPE,
                fly.Position,
                Vector.Zero,
                player
            ):ToFamiliar()
            newFly:GetSprite().Color = FLY_COLOR

            data["bloodGuppyCooldown"] = frameCount + COOLDOWN_TIME
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        if familiar.SubType == FLY_SUBTYPE then
            familiar:GetSprite().Color = FLY_COLOR
        end
    end,
    FamiliarVariant.BLUE_FLY
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
    ---@param familiar EntityFamiliar
    ---@param collider Entity
    ---@param low boolean
    function(_, familiar, collider, low)
        local player = familiar.SpawnerEntity:ToPlayer()

        if not player or not player:HasCollectible(ITEM_ID) then
            return
        end

        local npc = collider:ToNPC()

        if not npc or not npc:IsVulnerableEnemy() then
            return
        end

        if familiar:GetData().hasBrimstoneEffect then
            return
        end

        if familiar.SubType == FLY_SUBTYPE then
            local effect = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.BRIMSTONE_SWIRL,
                0,
                familiar.Position,
                Vector.Zero,
                player
            )
            effect.CollisionDamage = player.Damage

            familiar:GetData().hasBrimstoneEffect = true
        end
    end,
    FamiliarVariant.BLUE_FLY
)

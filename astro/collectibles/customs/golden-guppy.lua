---

Astro.Collectible.GOLDEN_GUPPY = Isaac.GetItemIdByName("Golden Guppy")

local ITEM_ID = Astro.Collectible.GOLDEN_GUPPY

local BASE_FLY_CHANCE = 0.5
local LUCK_FLY_CHANCE = 0.01

local COOLDOWN_TIME = 15

---

local FLY_SUBTYPE = 1005
local FLY_COLOR = Color(1, 1, 1, 1, 1, 0.8, 0)

if EID then
    Astro:AddEIDCollectible(
        ITEM_ID,
        "황금 구피",
        "...",
        "파란 파리가 소환될 때, 50% 확률로 황금 파리를 추가로 소환합니다." ..
        "#{{ArrowGrayRight}] 황금 파리는 적에게 접촉시 3초간 접촉한 적을 멈추게 만들며, 멈춘 적은 처치시 {{Coin}}동전을 1~3개 드랍합니다." ..
        "#{{LuckSmall}} 행운이 50 이상일 때 100% 확률 행운 1당 +1%p"
    )

    Astro:AddEIDCollectible(
        ITEM_ID,
        "Golden Guppy", "",
        "50% chance to spawn an additional golden fly." ..
        "#Golden flies turn monsters into gold for 3 seconds when dealing damage." ..
        "#{{Luck}} 100% chance at 50 luck (+1%p per luck)",
        nil,
        "en_us"
    )
end

-- TODO: 나중에 새로운 콜백 작성할 것
Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local data = Astro.SaveManager.GetRunSave(player)
        local goldenHearts = player:GetGoldenHearts()

        if data["prevGoldenHearts"] == nil then
            data["prevGoldenHearts"] = goldenHearts
            return
        end

        if data["prevGoldenHearts"] > goldenHearts and player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then
            local guppyItems = Astro:FindGuppyItems(player)
            
            for _, guppyItem in ipairs(guppyItems) do
                guppyItem:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, guppyItem.Position, guppyItem.Velocity, nil)
            end
        end

        data["prevGoldenHearts"] = goldenHearts
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

        if (data["goldenGuppyCooldown"] == nil or data["goldenGuppyCooldown"] < frameCount) and rng:RandomFloat() < flyChance then
            local newFly = Isaac.Spawn(
                EntityType.ENTITY_FAMILIAR,
                FamiliarVariant.BLUE_FLY,
                FLY_SUBTYPE,
                fly.Position,
                Vector.Zero,
                player
            ):ToFamiliar()
            newFly:GetSprite().Color = FLY_COLOR

            data["goldenGuppyCooldown"] = frameCount + COOLDOWN_TIME
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
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    ---@param entity Entity
    ---@param amount number
    ---@param damageFlags number
    ---@param source EntityRef
    ---@param countdownFrames number
    function(_, entity, amount, damageFlags, source, countdownFrames)
        if source.Type ~= EntityType.ENTITY_FAMILIAR or source.Variant ~= FamiliarVariant.BLUE_FLY or source.Entity.SubType ~= FLY_SUBTYPE then
            return
        end

        entity:AddMidasFreeze(EntityRef(source.Entity.SpawnerEntity), 3 * 30)
    end
)

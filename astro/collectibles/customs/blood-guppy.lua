Astro.Collectible.BLOOD_GUPPY = Isaac.GetItemIdByName("Brimstone Guppy")
local ITEM_ID = Astro.Collectible.BLOOD_GUPPY

---

local BASE_FLY_CHANCE = 0.5
local LUCK_FLY_CHANCE = 0.01

local COOLDOWN_TIME = 15

local FLY_SUBTYPE = 1001
local FLY_COLOR = Color(1, 1, 1, 1)
FLY_COLOR:SetColorize(0.8, 0.6, 0.6, 10)

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "유황불 구피",
                "너 대신 희생한",
                "파란 아군 파리가 소환될 때 50% 확률로 유황 파리를 소환합니다." ..
                "#유황 파리는 적에게 접촉 시 공격력 x2의 접촉 피해를 주고 유황 소용돌이를 소환합니다." ..
                "#소용돌이는 다단히트로 최대 22번의 피해를 줍니다." ..
                "#{{LuckSmall}} 행운 50 이상일 때 100% 확률 (행운 1당 +1%p)"
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Brimstone Guppy", "",
                "50% chance to spawn a brimstone fly when spawned blue fly" ..
                "#Brimstone fly deal 2x Isaac's damage and spawn a Brimstone swirl" ..
                "#{{Damage}} It deals 22x Isaac's damage over 4.33 seconds" ..
                "#{{Luck}} 100% chance at 50 Luck (+1%p per Luck)",
                nil, "en_us"
            )
        end
    end
)

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
            newFly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

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
            effect:GetData()._ASTRO_bloodGuppySfx = true
            effect:GetData()._ASTRO_bloodGuppyState1 = true
            
            local effect2 = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.HUSH_LASER_UP,
                0,
                effect.Position + Vector(0, 3),
                Vector.Zero,
                player
            )
            effect2.Color = Color(0.75, 0, 0, 1)
            effect2:SetColor(Color(0, 0, 0, 0), 1, 1, false, false)
            Astro:ScheduleForUpdate(function() effect2:Die() end, 50)

            familiar:GetData().hasBrimstoneEffect = true
        end
    end,
    FamiliarVariant.BLUE_FLY
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local eData = effect:GetData()
        if eData._ASTRO_bloodGuppySfx then
            local sfx = SFXManager()
            sfx:Play(Astro.SoundEffect.BLOOD_GUPPY_SWIRL, 0.75)
            eData._ASTRO_bloodGuppySfx = nil
        end

        if eData._ASTRO_bloodGuppyState1 then
            effect.State = 1
        end
    end,
    EffectVariant.BRIMSTONE_SWIRL
)
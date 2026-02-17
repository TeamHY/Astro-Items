Astro.Collectible.DIVINE_GUPPY = Isaac.GetItemIdByName("Divine Guppy")
local ITEM_ID = Astro.Collectible.DIVINE_GUPPY

---

local BASE_FLY_CHANCE = 0.5
local LUCK_FLY_CHANCE = 0.01

local COOLDOWN_TIME = 15

local FLY_SUBTYPE = 1002

---

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro.EID:AddCollectible(
                ITEM_ID,
                "신성한 구피",
                "너 대신 축복받은",
                "파란 파리가 소환될 때 50% 확률로 신성한 파리를 추가로 소환합니다." ..
                "#신성한 파리는 적에게 접촉 시 그 자리에 빛줄기를 내립니다." ..
                "#{{LuckSmall}} 행운 50 이상일 때 100% 확률 (행운 1당 +1%p)"
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Divine Guppy", "",
                "50% chance to spawn a holy fly when spawned blue fly" ..
                "#Holy flies spawn a beam of light to enemies on contact" ..
                "#{{Luck}} 100% chance at 50 Luck (+1%p per Luck)",
                nil, "en_us"
            )
            
            Astro.EID.LuckFormulas["5.100." .. tostring(ITEM_ID)] = function(luck, num)
                return ((BASE_FLY_CHANCE + luck * LUCK_FLY_CHANCE) * 100)
            end
        end
    end
)

Astro:AddUpgradeAction(
    function(player)
        if player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) and player:GetEternalHearts() > 0 then
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

        if (data["divineGuppyCooldown"] == nil or data["divineGuppyCooldown"] < frameCount) and rng:RandomFloat() < flyChance then
            local newFly = Isaac.Spawn(
                EntityType.ENTITY_FAMILIAR,
                FamiliarVariant.BLUE_FLY,
                FLY_SUBTYPE,
                fly.Position,
                Vector.Zero,
                player
            ):ToFamiliar()
            newFly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

            local flySprite = newFly:GetSprite()
            flySprite:ReplaceSpritesheet(0, "gfx/familiar/holy_fly.png")
            flySprite:LoadGraphics()

            data["divineGuppyCooldown"] = frameCount + COOLDOWN_TIME
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_FAMILIAR_INIT,
    ---@param familiar EntityFamiliar
    function(_, familiar)
        if familiar.SubType == FLY_SUBTYPE then
            local flySprite = familiar:GetSprite()
            flySprite:ReplaceSpritesheet(0, "gfx/familiar/holy_fly.png")
            flySprite:LoadGraphics()
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

        if familiar:GetData().hasEffect then
            return
        end

        if familiar.SubType == FLY_SUBTYPE then
            local effect = Isaac.Spawn(
                EntityType.ENTITY_EFFECT,
                EffectVariant.CRACK_THE_SKY,
                0,
                familiar.Position,
                Vector.Zero,
                player
            )
            effect.Parent = player
            effect:ToEffect().CollisionDamage = player.Damage + 20

            familiar:GetData().hasEffect = true
        end
    end,
    FamiliarVariant.BLUE_FLY
)

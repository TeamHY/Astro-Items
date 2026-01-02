Astro.Collectible.BLIGHTED_GUPPY = Isaac.GetItemIdByName("Blighted Guppy")
local ITEM_ID = Astro.Collectible.BLIGHTED_GUPPY

---

local BASE_FLY_CHANCE = 0.5
local LUCK_FLY_CHANCE = 0.01

local COOLDOWN_TIME = 15

local FLY_SUBTYPE = 1003

---


Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            --[[
            local CRAFT_HINT = {
                ["ko_kr"] = "#{{DiceRoom}} {{ColorYellow}}주사위방{{CR}}에서 사용하여 변환",
                ["en_us"] = "#{{DiceRoom}} Can be transformed {{ColorYellow}}using it in the Dice Room{{CR}}",
            }
            Astro.EID:AddCraftHint(CollectibleType.COLLECTIBLE_D6, CRAFT_HINT)]]

            Astro.EID:AddCollectible(
                ITEM_ID,
                "부패한 구피",
                "너 대신 죽어준",
                "파란 아군 파리가 소환될 때 50% 확률로 파란 파리를 추가로 소환합니다." ..
                "#{{LuckSmall}} 행운 50 이상일 때 100% 확률 (행운 1당 +1%p)"
            )

            Astro.EID:AddCollectible(
                ITEM_ID,
                "Blighted Guppy", "",
                "50% chance to spawn an additional blue fly when spawned blue fly" ..
                "#{{Luck}} 100% chance at 50 Luck (+1%p per Luck)",
                nil, "en_us"
            )
        end
    end
)

Astro:AddUpgradeAction(
    function(player)
        if player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) and player:GetRottenHearts() > 0 then
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

        if (data["blightedGuppyCooldown"] == nil or data["blightedGuppyCooldown"] < frameCount) and rng:RandomFloat() < flyChance then
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
            flySprite:ReplaceSpritesheet(0, "gfx/familiar/rotten_fly.png")
            flySprite:LoadGraphics()

            data["blightedGuppyCooldown"] = frameCount + COOLDOWN_TIME
        end
    end
)

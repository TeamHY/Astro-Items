---

Astro.Collectible.SKELETON_GUPPY = Isaac.GetItemIdByName("Skeleton Guppy")

local ITEM_ID = Astro.Collectible.SKELETON_GUPPY

local BASE_FLY_CHANCE = 0.5
local LUCK_FLY_CHANCE = 0.01

local COOLDOWN_TIME = 15

local BONE_DAMAGE_MULTIPLIER = 1

---

local FLY_SUBTYPE = 1004
local FLY_COLOR = Color(1, 1, 1, 1, 0.4, 0.4, 0.2)

if EID then
    Astro:AddEIDCollectible(
        ITEM_ID,
        "스켈레톤 구피", "...",
        "파리가 소환될 때 50% 확률로 뼈 파리를 추가로 소환합니다." ..
        "#{{ArrowGrayRight}} 뼈 파리는 적에게 접촉시 4방향으로 무언가에 부딪힐 때 1~3갈래로 갈라지는 뼈 눈물을 발사합니다." ..
        "#{{LuckSmall}} 행운 50 이상일 때 100% 확률 (행운 1당 +1%p)"
    )

    Astro:AddEIDCollectible2(
        "en_us",
        ITEM_ID,
        "Skeleton Guppy",
        "50% chance to spawn an additional bone-themed fly." ..
        "#Bone flies deal bone splash damage when hitting monsters." ..
        "#{{Luck}} 100% chance at 50 luck (+1%p per luck)"
    )
end

-- TODO: 나중에 새로운 콜백 작성할 것
Astro:AddCallback(
    ModCallbacks.MC_POST_PLAYER_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        local data = Astro.SaveManager.GetRunSave(player)
        local boneHearts = player:GetBoneHearts()

        if data["prevBoneHearts"] == nil then
            data["prevBoneHearts"] = boneHearts
            return
        end

        if data["prevBoneHearts"] > boneHearts and player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then
            local guppyItems = Astro:FindGuppyItems(player)
            
            for _, guppyItem in ipairs(guppyItems) do
                guppyItem:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ITEM_ID)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, guppyItem.Position, guppyItem.Velocity, nil)
            end
        end

        data["prevBoneHearts"] = boneHearts
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

        if (data["skeletonGuppyCooldown"] == nil or data["skeletonGuppyCooldown"] < frameCount) and rng:RandomFloat() < flyChance then
            local newFly = Isaac.Spawn(
                EntityType.ENTITY_FAMILIAR,
                FamiliarVariant.BLUE_FLY,
                FLY_SUBTYPE,
                fly.Position,
                Vector.Zero,
                player
            ):ToFamiliar()
            newFly:GetSprite().Color = FLY_COLOR

            data["skeletonGuppyCooldown"] = frameCount + COOLDOWN_TIME
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

        if familiar:GetData().hasEffect then
            return
        end

        if familiar.SubType == FLY_SUBTYPE then
            local baseAngle = math.random() * 360
            
            for i = 0, 3 do
                local angle = baseAngle + (i * 90)
                local radians = math.rad(angle)
                local direction = Vector(math.cos(radians), math.sin(radians)) * 2
                
                local tear = player:FireTear(familiar.Position, direction, true, true, true, nil, BONE_DAMAGE_MULTIPLIER)
                tear:ChangeVariant(TearVariant.BONE)
                tear.Scale = 0.7
                tear.Height = tear.Height / 2
            end

            familiar:GetData().hasEffect = true
        end
    end,
    FamiliarVariant.BLUE_FLY
)

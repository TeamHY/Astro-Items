local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.FLAMMES_GRIMOIRE = Isaac.GetItemIdByName("Flamme's Grimoire")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.FLAMMES_GRIMOIRE,
        "플람메의 마도서",
        "...",
        "방 입장시 모든 돌 위에 꽃을 피웁니다." ..
        "#가시 돌은 입장시 제거됩니다." ..
        "#방을 클리어하면 모든 돌이 제거됩니다."
    )
end

local FLOWER_EFFECT_VARIANT = Isaac.GetEntityVariantByName("Flamme's Flower")

local function SpawnFlowersOnRock(position)
    local rng = RNG()
    rng:SetSeed(Random() + 1, 35)
    
    local bigFlowerCount = rng:RandomInt(2)
    for i = 1, bigFlowerCount do
        local offsetX = (rng:RandomFloat() - 0.5) * 40
        local offsetY = (rng:RandomFloat() - 0.5) * 40
        local flowerPosition = position + Vector(offsetX, offsetY)
        
        local flowerEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, FLOWER_EFFECT_VARIANT, 0, flowerPosition, Vector.Zero, nil)
        flowerEffect:GetSprite():Play("big", true)
    end
    
    local offsetX = (rng:RandomFloat() - 0.5) * 40
    local offsetY = (rng:RandomFloat() - 0.5) * 40
    local flowerPosition = position + Vector(offsetX, offsetY)
    
    local flowerEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, FLOWER_EFFECT_VARIANT, 0, flowerPosition, Vector.Zero, nil)
    flowerEffect:GetSprite():Play("medium", true)
    
    local smallFlowerCount = rng:RandomInt(2) + 2
    for i = 1, smallFlowerCount do
        local offsetX = (rng:RandomFloat() - 0.5) * 40
        local offsetY = (rng:RandomFloat() - 0.5) * 40
        local flowerPosition = position + Vector(offsetX, offsetY)
        
        local flowerEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, FLOWER_EFFECT_VARIANT, 0, flowerPosition, Vector.Zero, nil)
        flowerEffect:GetSprite():Play("small", true)
    end
end

local function SpawnFlowersOnRocksOnly()
    local room = Game():GetRoom()
    local width = room:GetGridWidth()
    local height = room:GetGridHeight()
    
    for i = 0, width * height - 1 do
        local gridEntity = room:GetGridEntity(i)
        local rock = gridEntity and gridEntity:ToRock()
        
        if rock and rock.State ~= 2 then
            if rock:GetType() == GridEntityType.GRID_ROCK_SPIKED then
                rock:Destroy(false)
                goto continue
            end

            local position = room:GetGridPosition(i)
            SpawnFlowersOnRock(position)
        end
        ::continue::
    end
end

local function DestroyAllRocks()
    local room = Game():GetRoom()
    local width = room:GetGridWidth()
    local height = room:GetGridHeight()
    
    for i = 0, width * height - 1 do
        local gridEntity = room:GetGridEntity(i)
        local rock = gridEntity and gridEntity:ToRock()

        if rock then
            rock:Destroy(false)
        end
    end
end

local function RemoveAllFlowers()
    for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, FLOWER_EFFECT_VARIANT)) do
        effect:Remove()
    end
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Game():GetRoom():IsFirstVisit() then
            SpawnFlowersOnRocksOnly()
        end
    end,
    Astro.Collectible.FLAMMES_GRIMOIRE
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.FLAMMES_GRIMOIRE) then
            SpawnFlowersOnRocksOnly()

            if Game():GetRoom():IsClear() then
                local roomIndex = Game():GetLevel():GetCurrentRoomIndex()

                Astro:ScheduleForUpdate(
                    function()
                        if Game():GetLevel():GetCurrentRoomIndex() ~= roomIndex then
                            return
                        end

                        DestroyAllRocks()
                        RemoveAllFlowers()
                    end,
                    60
                )
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.FLAMMES_GRIMOIRE) then
            DestroyAllRocks()
            RemoveAllFlowers()
        end
    end
)

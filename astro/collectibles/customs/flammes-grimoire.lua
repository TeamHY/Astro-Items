local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.FLAMMES_GRIMOIRE = Isaac.GetItemIdByName("Flamme's Grimoire")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.FLAMMES_GRIMOIRE,
        "플람메의 마도서",
        "마법은, 사람의 마음을 이어주는 증거야",
        "방 입장 시 모든 가시 돌이 제거되며, 돌 위에 꽃을 피웁니다." ..
        "#{{ArrowGrayRight}} 꽃이 핀 돌은 방 클리어 시 파괴됩니다."
    )
end

local FLOWER_EFFECT_VARIANT = Isaac.GetEntityVariantByName("Flamme's Flower")

local function SpawnFlowersOnRocks()
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
            local flowerEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, FLOWER_EFFECT_VARIANT, 0, position, Vector.Zero, nil)
            flowerEffect:GetSprite():Play("open", true)
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

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local sprite = effect:GetSprite()

        if sprite:IsFinished("open") then
            sprite:Play("idle", true)
        end
    end,
    FLOWER_EFFECT_VARIANT
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Game():GetRoom():IsFirstVisit() then
            SpawnFlowersOnRocks()
        end
    end,
    Astro.Collectible.FLAMMES_GRIMOIRE
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.FLAMMES_GRIMOIRE) then
            SpawnFlowersOnRocks()

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

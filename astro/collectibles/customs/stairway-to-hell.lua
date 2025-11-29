local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.STAIRWAY_TO_HELL = Isaac.GetItemIdByName("Stairway to Hell")

local STAIRWAY_TO_HELL_VARIANT = 3103
local FOOL_DEVIL_BUM_VARIANT = 3106

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.STAIRWAY_TO_HELL,
                "지옥의 계단",
                "기다린 것을 얻을 수 있기를",
                "{{DevilRoom}} 스테이지 첫 방에 {{BrokenHeart}}소지 불가능 체력으로 거래하는 악마방으로 갈 수 있는 사다리가 생성됩니다." ..
                "#!!! 사다리는 방을 벗어나면 사라집니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.STAIRWAY_TO_HELL) then
            local level = Game():GetLevel()
            local room = level:GetCurrentRoom()

            if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() and room:IsFirstVisit() then
                Astro:Spawn(EntityType.ENTITY_EFFECT, STAIRWAY_TO_HELL_VARIANT, 0, room:GetGridPosition(19))
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    ---@param effect EntityEffect
    function(_, effect)
        local players = Isaac.FindInRadius(effect.Position, 20, EntityPartition.PLAYER)

        if #players > 0 then
            Isaac.ExecuteCommand("goto s.devil")

            Astro:ScheduleForUpdate(
                function()
                    local level = Game():GetLevel()
                    local enterDoor = level.EnterDoor
                    local room = level:GetCurrentRoom()
                    local spawnPos, spawnOffset = Vector(0, 0), Vector(0, 0)

                    if enterDoor == DoorSlot.LEFT0 or enterDoor == DoorSlot.UP0 then
                        spawnPos = room:GetDoorSlotPosition(DoorSlot.RIGHT0)
                        spawnOffset = Vector(-100, 50)
                    elseif enterDoor == DoorSlot.RIGHT0 or enterDoor == DoorSlot.DOWN0 then
                        spawnPos = room:GetDoorSlotPosition(DoorSlot.LEFT0)
                        spawnOffset = Vector(100, 50)
                    end
                    Astro:Spawn(EntityType.ENTITY_SLOT, FOOL_DEVIL_BUM_VARIANT, 0, spawnPos + spawnOffset)
                end,
                3
            )
        end
    end,
    STAIRWAY_TO_HELL_VARIANT
)


------ 카드 주는 거지 ------
Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_INIT,
    ---@param slot Entity
    function(_, slot)
        slot.SpriteOffset = Vector(0, -10)
    end,
    FOOL_DEVIL_BUM_VARIANT
)

Astro:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    function(_)
        local slots = Isaac.FindByType(EntityType.ENTITY_SLOT, FOOL_DEVIL_BUM_VARIANT, -1, true)
        if #slots > 0 then
            for _, slot in ipairs(slots) do
                slot.SpriteOffset = Vector(0, -10)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_SLOT_UPDATE,
    ---@param slot Entity
    function(_, slot)
        slot.SpriteOffset = Vector(0, -10)
        local sprite = slot:GetSprite()

        if sprite:IsEventTriggered("Drop") then
            Astro:SpawnCard(Card.CARD_FOOL, slot.Position)
        end

        if sprite:IsFinished("Idle") then
            sprite:Play("exit")
        elseif sprite:IsFinished("exit") then
            slot:Remove()
        end
    end,
    FOOL_DEVIL_BUM_VARIANT
)
Astro.Collectible.STAIRWAY_TO_HELL = Isaac.GetItemIdByName("Stairway to Hell")

local STAIRWAY_TO_HELL_VARIANT = 3103

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.STAIRWAY_TO_HELL,
                "지옥의 계단",
                "기다린 것을 얻을 수 있기를",
                "{{DevilRoom}} 스테이지 첫 방에 악마방으로 갈 수 있는 사다리가 생성됩니다.#!!! 사다리는 방을 벗어나면 사라집니다."
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
        end
    end,
    STAIRWAY_TO_HELL_VARIANT
)

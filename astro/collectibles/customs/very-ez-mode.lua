local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.VERY_EZ_MODE = Isaac.GetItemIdByName("Very EZ Mode")

local collectibles = {}

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        collectibles = {
            CollectibleType.COLLECTIBLE_COMPASS,
            CollectibleType.COLLECTIBLE_PSY_FLY,
            CollectibleType.COLLECTIBLE_HOLY_MANTLE,
            CollectibleType.COLLECTIBLE_DARK_ARTS,
            CollectibleType.COLLECTIBLE_LOST_CONTACT,
            CollectibleType.COLLECTIBLE_TREASURE_MAP,
            CollectibleType.COLLECTIBLE_MIND,
            CollectibleType.COLLECTIBLE_BLUE_MAP,
            CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM,
            CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
            CollectibleType.COLLECTIBLE_SPELUNKER_HAT,
            Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS,
            Astro.Collectible.SOL_EX,
            Astro.Collectible.WARD,
            Astro.Collectible.PINK_WARD,
        }

        if EID then
            local veryEZModeEIDString = ""
        
            for _, collectible in ipairs(collectibles) do
                veryEZModeEIDString = veryEZModeEIDString .. "{{Collectible" .. collectible .. "}} "
            end

        
            Astro:AddEIDCollectible(Astro.Collectible.VERY_EZ_MODE, "엄청 쉬운 모드", "...", "후반 스테이지 체력 제한 시스템이 6칸만 적용됩니다.#소울 하트 1개가 증가됩니다.#!!! 아래 아이템이 등장하지 않습니다.#" .. veryEZModeEIDString)
        end
    end
)

-- Astro:AddCallback(
--     ModCallbacks.MC_POST_NEW_ROOM,
--     function(_)
--         local level = Game():GetLevel()
--         local currentRoom = level:GetCurrentRoom()

--         if Astro:CheckFirstVisitFrame(currentRoom) then
--             if level:GetAbsoluteStage() == LevelStage.STAGE1_1 and level:GetCurrentRoomIndex() == 84 then
--                 Astro:SpawnCollectible(Astro.Collectible.VERY_EZ_MODE, currentRoom:GetGridPosition(41), nil, true)
--             end
--         end
--     end
-- )

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()

        for _, collectible in ipairs(collectibles) do
            itemPool:RemoveCollectible(collectible)
        end
    end,
    Astro.Collectible.VERY_EZ_MODE
)

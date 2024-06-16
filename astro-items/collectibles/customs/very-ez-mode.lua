local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.VERY_EZ_MODE = Isaac.GetItemIdByName("Very EZ Mode")

local collectibles = {}

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        collectibles = {
            CollectibleType.COLLECTIBLE_COMPASS,
            CollectibleType.COLLECTIBLE_TREASURE_MAP,
            CollectibleType.COLLECTIBLE_MIND,
            CollectibleType.COLLECTIBLE_BLUE_MAP,
            CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM,
            CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
            AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS,
        }

        if EID then
            local veryEZModeEIDString = ""
        
            for _, collectible in ipairs(collectibles) do
                veryEZModeEIDString = veryEZModeEIDString .. "{{Collectible" .. collectible .. "}} "
            end

        
            AstroItems:AddEIDCollectible(AstroItems.Collectible.VERY_EZ_MODE, "엄청 쉬운 모드", "...", "후반 스테이지 체력 제한 시스템이 작동하지 않습니다.#!!! 아래 아이템이 등장하지 않습니다.#" .. veryEZModeEIDString)
        end
    end
)

-- AstroItems:AddCallback(
--     ModCallbacks.MC_POST_NEW_ROOM,
--     function(_)
--         local level = Game():GetLevel()
--         local currentRoom = level:GetCurrentRoom()

--         if AstroItems:CheckFirstVisitFrame(currentRoom) then
--             if level:GetAbsoluteStage() == LevelStage.STAGE1_1 and level:GetCurrentRoomIndex() == 84 then
--                 AstroItems:SpawnCollectible(AstroItems.Collectible.VERY_EZ_MODE, currentRoom:GetGridPosition(41), nil, true)
--             end
--         end
--     end
-- )

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()

        for _, collectible in ipairs(collectibles) do
            itemPool:RemoveCollectible(collectible)
        end
    end,
    AstroItems.Collectible.VERY_EZ_MODE
)

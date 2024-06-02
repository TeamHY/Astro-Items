local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.CLEANER = Isaac.GetItemIdByName("Cleaner")

AstroItems:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        AstroItems.CleanerList = {
            CollectibleType.COLLECTIBLE_MOMS_KNIFE,
            CollectibleType.COLLECTIBLE_BRIMSTONE,
            CollectibleType.COLLECTIBLE_IPECAC,
            CollectibleType.COLLECTIBLE_EPIC_FETUS,
            CollectibleType.COLLECTIBLE_DR_FETUS,
            CollectibleType.COLLECTIBLE_TECH_X,
            CollectibleType.COLLECTIBLE_TECHNOLOGY,
            CollectibleType.COLLECTIBLE_TECHNOLOGY_2,
            CollectibleType.COLLECTIBLE_SPIRIT_SWORD,
            CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE
        }

        if EID then
            AstroItems.CleanerEIDString = ""

            for _, collectible in ipairs(AstroItems.CleanerList) do
                AstroItems.CleanerEIDString = AstroItems.CleanerEIDString .. "{{Collectible" .. collectible .. "}} "
            end

            AstroItems:AddEIDCollectible(
                AstroItems.Collectible.CLEANER,
                "클리너",
                "...",
                "!!! 효과가 발동한 뒤 사라집니다.#!!! 획득 시 아래 아이템이 제거됩니다.#" .. AstroItems.CleanerEIDString
            )
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        for _, collectible in ipairs(AstroItems.CleanerList) do
            AstroItems:RemoveAllCollectible(player, collectible)
        end

        AstroItems:RemoveAllCollectible(player, AstroItems.Collectible.CLEANER)
    end,
    AstroItems.Collectible.CLEANER
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local level = Game():GetLevel()
        local stage = level:GetAbsoluteStage()
        local currentRoom = level:GetCurrentRoom()
        local currentRoomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())

        if currentRoom:GetFrameCount() <= 0 and currentRoom:IsFirstVisit() then
            if (currentRoomDesc.Data.Name == "Starting Room" and stage == LevelStage.STAGE4_3) or (currentRoomDesc.Data.Variant == 0 and stage == LevelStage.STAGE6) then
                AstroItems:SpawnCollectible(AstroItems.Collectible.CLEANER, currentRoom:GetTopLeftPos(), nil, true)
            end
        end
    end
)

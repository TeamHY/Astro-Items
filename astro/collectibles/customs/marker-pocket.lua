local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.MARKER_POCKET = Isaac.GetItemIdByName("Marker Pocket")

local markerPocketItems = {}

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        markerPocketItems = {
            CollectibleType.COLLECTIBLE_SAD_ONION,
            CollectibleType.COLLECTIBLE_INNER_EYE,
            CollectibleType.COLLECTIBLE_SPOON_BENDER,
        }

        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.MARKER_POCKET, 
                "표식 주머니", 
                "...", 
                "{{SuperSecretRoom}}일급비밀방에서 사용 시 소지한 아이템 중 하나와 정해진 아이템 중 하나를 소환합니다. 하나를 선택하면 나머지는 사라집니다." ..
                "#{{Room}} 1스테이지의 맵에 {{SuperSecretRoom}}일급비밀방 위치를 표시합니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        if Astro:HasCollectible(Astro.Collectible.MARKER_POCKET) then
            if Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE1_1 then
                Astro:DisplayRoom(RoomType.ROOM_SUPERSECRET)
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE1_1 then
            Astro:DisplayRoom(RoomType.ROOM_SUPERSECRET)
        end
    end,
    Astro.Collectible.MARKER_POCKET
)

Astro:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local room = Game():GetRoom()

        if room:GetType() ~= RoomType.ROOM_SUPERSECRET then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local inventory = Astro:getPlayerInventory(playerWhoUsedItem, false)

        local hadCollectable = Astro:GetRandomCollectibles(inventory, rngObj, 1, Astro.Collectible.MARKER_POCKET, true)

        if hadCollectable[1] ~= nil then
            Astro:SpawnCollectible(hadCollectable[1], playerWhoUsedItem.Position, Astro.Collectible.MARKER_POCKET)
        end

        local newItem = markerPocketItems[rngObj:RandomInt(#markerPocketItems) + 1]
        Astro:SpawnCollectible(newItem, playerWhoUsedItem.Position, Astro.Collectible.MARKER_POCKET)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.MARKER_POCKET
)

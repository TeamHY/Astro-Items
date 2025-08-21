---

local USE_SOUND = Isaac.GetSoundIdByName("Specialsummon")

local USE_SOUND_VOLUME = 1 -- 0 ~ 1

local SPAWN_COLLECTIBLE_COUNT = 3

---

local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.CURSE_OF_ARAMATIR = Isaac.GetItemIdByName("Curse of Aramatir")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.CURSE_OF_ARAMATIR,
                "금주 아라마티아",
                "...",
                "!!! 일회용"..
                "#!!! 소지중인 아이템이 없거나 {{SuperSecretRoom}}일급비밀방이 아니면 사용 불가" ..
                "#사용 시 소지중인 {{Quality3}}/{{Quality4}}등급 아이템을 " .. SPAWN_COLLECTIBLE_COUNT .. "개 소환하며;" ..
                "#{{ArrowGrayRight}} 소환된 아이템 중 하나를 선택하면 나머지는 사라집니다." ..
                "#{{ArrowGrayRight}} {{ColorRed}}소환된 아이템은 방을 나가면 사라집니다." ..
                "#{{Room}} 1스테이지의 맵에 {{SuperSecretRoom}}일급비밀방 위치를 표시합니다." ..
                "#Water Enchantress와 Illegal Knight는 스테이지마다 한 번 사용 가능합니다."
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if Astro:IsWaterEnchantress(player) then
                local data = Astro:GetPersistentPlayerData(player)

                data.curseOfAramatir = {
                    used = false
                }
            end
        end

        if Astro:HasCollectible(Astro.Collectible.CURSE_OF_ARAMATIR) then
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
    Astro.Collectible.CURSE_OF_ARAMATIR
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1)

        for _, entity in ipairs(entities) do
            if entity:ToPickup().OptionsPickupIndex == Astro.Collectible.CURSE_OF_ARAMATIR then
                entity:Remove()
            end
        end
    end
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
        if Game():GetLevel():GetCurrentRoom():GetType() ~= RoomType.ROOM_SUPERSECRET then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local playerData = Astro:GetPersistentPlayerData(playerWhoUsedItem)

        if Astro:IsWaterEnchantress(playerWhoUsedItem) then
            if playerData.curseOfAramatir and playerData.curseOfAramatir.used then
                return {
                    Discharge = false,
                    Remove = false,
                    ShowAnim = false,
                }
            end
        end
        
        local rng = playerWhoUsedItem:GetCollectibleRNG(Astro.Collectible.CURSE_OF_ARAMATIR)
        
        local inventory = Astro:Filter(
            Astro:getPlayerInventory(playerWhoUsedItem, false),
            function (item)
                local quality = Isaac.GetItemConfig():GetCollectible(item).Quality

                return quality >= 3
            end
        )

        local hadCollectables = Astro:GetRandomCollectibles(inventory, rng, SPAWN_COLLECTIBLE_COUNT, Astro.Collectible.CURSE_OF_ARAMATIR, true)

        if hadCollectables[1] == nil then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        for _, hadCollectable in ipairs(hadCollectables) do
            Astro:SpawnCollectible(hadCollectable, playerWhoUsedItem.Position, Astro.Collectible.CURSE_OF_ARAMATIR)
        end

        SFXManager():Play(USE_SOUND, USE_SOUND_VOLUME)

        if Astro:IsWaterEnchantress(playerWhoUsedItem) then
            playerData.curseOfAramatir = {
                used = true
            }

            return {
                Discharge = true,
                Remove = false,
                ShowAnim = true,
            }
        end

        return {
            Discharge = true,
            Remove = true,
            ShowAnim = true,
        }
    end,
    Astro.Collectible.CURSE_OF_ARAMATIR
)

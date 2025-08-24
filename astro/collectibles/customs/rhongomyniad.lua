---

local MAX_STACK = 5

local BASE_CHANCE = 0.2

-- 럭 1당 추가 확률
local LUCK_CHANCE = 0.02

---

Astro.Collectible.RHONGOMYNIAD = Isaac.GetItemIdByName("Rhongomyniad")

local collectibles = {}

local optionsPickupIndex = Astro.Collectible.RHONGOMYNIAD * 10000

Astro:AddCallback(
    ModCallbacks.MC_POST_GAME_STARTED,
    function(_, isContinued)
        collectibles = {
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
            local rhongomyniadEIDString = ""
        
            for _, collectible in ipairs(collectibles) do
                rhongomyniadEIDString = rhongomyniadEIDString .. "{{Collectible" .. collectible .. "}} "
            end
        
            Astro:AddEIDCollectible(
                Astro.Collectible.RHONGOMYNIAD,
                "론고미니아드",
                "...",
                "!!! 일회용" ..
                "#!!! {{SecretRoom}}비밀방과 {{SuperSecretRoom}}일급비밀방에서 사용 불가" ..
                "#방 클리어 시 20% 확률로 스택이 증가합니다." ..
                "#{{LuckSmall}} 행운 40 이상일 때 100% 확률 (행운 1당 +2%p)" ..
                "#사용 시 " .. rhongomyniadEIDString .. " 중에서 쌓인 스택만큼 아이템을 소환합니다." ..
                "#{{ArrowGrayRight}} 소환된 아이템은 {{ColorError}}방 이동 시 사라지며{{CR}}, 하나를 선택하면 나머지는 사라집니다."
            )

            EID:addPlayerCondition(
                "5.100." .. tostring(Astro.Collectible.RHONGOMYNIAD),
                { PlayerType.PLAYER_SAMSON },
                {
                    "!!! 일회용#!!!",
                    "!!!"
                },
                nil, "ko_kr", nil
            )
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == Astro.Collectible.RHONGOMYNIAD then
                    -- if player:GetPlayerType() == Astro.Players.WATER_ENCHANTRESS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                    --     player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    --     player:SetActiveCharge(100, j)
                    --     player:RemoveCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    -- else
                        player:SetActiveCharge(50, j)
                    -- end
                end
            end
        end
    end
)

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.RHONGOMYNIAD) then
                local room = Game():GetRoom()
        
                if room:GetType() ~= RoomType.ROOM_SECRET and room:GetType() ~= RoomType.ROOM_SUPERSECRET then
                    local data = Astro:GetPersistentPlayerData(player)
                    local stack = data["rhongomyniadStack"] or 0
        
                    if stack < MAX_STACK then
                        if rng:RandomFloat() < BASE_CHANCE + player.Luck * LUCK_CHANCE then
                            data["rhongomyniadStack"] = stack + 1
                        end
                    end
                end
            end
        end
    end
)


Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    function(_)
        local collectibles = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        
        for _, c in ipairs(collectibles) do
            if c:ToPickup().OptionsPickupIndex == optionsPickupIndex then
                c:Remove()
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
        local data = Astro:GetPersistentPlayerData(playerWhoUsedItem)
        local stack = data["rhongomyniadStack"] or 0

        if stack == 0 then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local items = Astro:GetRandomCollectibles(collectibles, rngObj, stack)

        for _, item in ipairs(items) do
            Astro:SpawnCollectible(item, playerWhoUsedItem.Position, optionsPickupIndex)
        end

        SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND)

        data["rhongomyniadStack"] = 0

        if playerWhoUsedItem:GetPlayerType() == PlayerType.PLAYER_SAMSON or playerWhoUsedItem:GetPlayerType() == PlayerType.PLAYER_SAMSON_B then
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
    Astro.Collectible.RHONGOMYNIAD
)

Astro:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(Astro.Collectible.RHONGOMYNIAD) then
                local data = Astro:GetPersistentPlayerData(player)
                local position = Astro:ToScreen(player.Position)

                Isaac.RenderText(
                    "x" .. (data["rhongomyniadStack"] or 0),
                    position.X - 12,
                    position.Y - 40,
                    1,
                    1,
                    0,
                    1
                )
            end
        end
    end
)

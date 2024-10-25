---

local MAX_STACK = 5

local BASE_CHANCE = 0.2

-- 럭 1당 추가 확률
local LUCK_CHANCE = 0.02

---

AstroItems.Collectible.RHONGOMYNIAD = Isaac.GetItemIdByName("Rhongomyniad")

local collectibles = {}

local optionsPickupIndex = AstroItems.Collectible.RHONGOMYNIAD * 10000

-- ✅일회용 아이템이지만 캐릭터가 삼손일경우 제거되지 않습니다
-- ✅기존 패시브 아이템에서 액티브 아이템으로 변경됩니다
-- ✅소지 시 캐릭터위에 1 스택이 표시됩니다 (큐브 시리즈랑 같으며, 자막 겹침 케어)
-- ✅방을 클리어 할때마다 확률(기본확률+행운확률)적으로 스택이 +1 증가됩니다 (최대 스택+5)
-- ✅사용 시, 스택에 개수만큼 공격형 아이템이 이지선다 형식으로 등장됩니다 (등장하는 공격 아이템은 기존 론고미니아드 아이템들 활용)
-- ✅악용 방지를 위해 아래 시스템을 추가합니다 (EID 느낌표 + 빨간자막)
-- └비밀방, 일급 비밀방에서는 사용할 수 없습니다
-- └아이템 소환 후, 방을 이동할 경우 해당 아이템들은 전부 제거됩니다 (에피파니 타니쉬드 아이작 병든 주사위가 사용 후 방을 나가면 제거됩니다. 코드짜기 어려우면 참고하면 될 듯 합니다. 이슈 발생되면 해당 사항은 무시하고 작업 해주세요)

AstroItems:AddCallback(
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
        
            AstroItems:AddEIDCollectible(
                AstroItems.Collectible.RHONGOMYNIAD,
                "론고미니아드",
                "...",
                "사용 시 스택만큼" .. rhongomyniadEIDString .. " 중에서 소환합니다. 하나를 선택하면 나머지는 사라집니다." ..
                "방 클리어 시 20% 확률로 스택이 증가합니다." ..
                "#!!! {{LuckSmall}}행운 수치 비례: 행운 40 이상일 때 100% 확률 ({{LuckSmall}}행운 1당 +2%p)" ..
                "#!!! {{ColorRed}}{{SecretRoom}}비밀방, {{SuperSecretRoom}}일급 비밀방에서는 사용할 수 없습니다." ..
                "#!!! {{ColorRed}}방을 이동할 경우 소환된 아이템들은 제거됩니다." ..
                "#!!! 일회용 아이템 (삼손 캐릭터 제외)"
            )
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.RHONGOMYNIAD) then
                local room = Game():GetRoom()
        
                if room:GetType() ~= RoomType.ROOM_SECRET and room:GetType() ~= RoomType.ROOM_SUPERSECRET then
                    local data = AstroItems:GetPersistentPlayerData(player)
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


AstroItems:AddCallback(
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


AstroItems:AddCallback(
    ModCallbacks.MC_USE_ITEM,
    ---@param collectibleID CollectibleType
    ---@param rngObj RNG
    ---@param playerWhoUsedItem EntityPlayer
    ---@param useFlags UseFlag
    ---@param activeSlot ActiveSlot
    ---@param varData integer
    function(_, collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
        local data = AstroItems:GetPersistentPlayerData(playerWhoUsedItem)
        local stack = data["rhongomyniadStack"] or 0

        if stack == 0 then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        local items = AstroItems:GetRandomCollectibles(collectibles, rngObj, stack)

        for _, item in ipairs(items) do
            AstroItems:SpawnCollectible(item, playerWhoUsedItem.Position, optionsPickupIndex)
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
    AstroItems.Collectible.RHONGOMYNIAD
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_RENDER,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)
        
            if player:HasCollectible(AstroItems.Collectible.RHONGOMYNIAD) then
                local data = AstroItems:GetPersistentPlayerData(player)
                local position = AstroItems:ToScreen(player.Position)

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

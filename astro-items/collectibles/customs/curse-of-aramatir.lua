AstroItems.Collectible.CURSE_OF_ARAMATIR = Isaac.GetItemIdByName("Curse of Aramatir")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.CURSE_OF_ARAMATIR, "금주 아라마티아", "...", "일급 비밀방에서 사용 시 소지된 아이템 중 1개를 소환합니다. 하나를 선택하면 나머지는 사라집니다.#스테이지 진입 시 쿨타임이 채워집니다.#성전의 수견사, 일리걸 나이트일 경우 아이템 2개를 소환합니다.#!!! 소지한 아이템이 없을 경우 사용할 수 없습니다.")
end

local useSound = Isaac.GetSoundIdByName('Specialsummon')
local useSoundVoulme = 1 -- 0 ~ 1

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function(_)
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            for j = 0, ActiveSlot.SLOT_POCKET2 do
                if player:GetActiveItem(j) == AstroItems.Collectible.CURSE_OF_ARAMATIR then
                    if player:GetPlayerType() == AstroItems.Players.WATER_ENCHANTRESS_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                        player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                        player:SetActiveCharge(100, j)
                        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                    else
                        player:SetActiveCharge(50, j)
                    end
                end
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
        local inventory = AstroItems:getPlayerInventory(playerWhoUsedItem, false)
        local rng = playerWhoUsedItem:GetCollectibleRNG(AstroItems.Collectible.CURSE_OF_ARAMATIR)

        local hadCollectables = {}

        if AstroItems:IsWaterEnchantress(playerWhoUsedItem) then
            hadCollectables = AstroItems:GetRandomCollectibles(inventory, rng, 2, AstroItems.Collectible.CURSE_OF_ARAMATIR, true)
        else
            hadCollectables = AstroItems:GetRandomCollectibles(inventory, rng, 1, AstroItems.Collectible.CURSE_OF_ARAMATIR, true)
        end

        if hadCollectables[1] == nil then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        if Game():GetLevel():GetCurrentRoom():GetType() ~= RoomType.ROOM_SUPERSECRET then
            return {
                Discharge = false,
                Remove = false,
                ShowAnim = false,
            }
        end

        for _, hadCollectable in ipairs(hadCollectables) do
            AstroItems:SpawnCollectible(hadCollectable, playerWhoUsedItem.Position, AstroItems.Collectible.CURSE_OF_ARAMATIR)
        end

        SFXManager():Play(useSound, useSoundVoulme)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end,
    AstroItems.Collectible.CURSE_OF_ARAMATIR
)

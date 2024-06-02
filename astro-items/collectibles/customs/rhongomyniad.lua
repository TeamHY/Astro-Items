AstroItems.Collectible.RHONGOMYNIAD = Isaac.GetItemIdByName("Rhongomyniad")

local collectibles = {}

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
        
            AstroItems:AddEIDCollectible(AstroItems.Collectible.RHONGOMYNIAD, "론고미니아드", "...", "스테이지를 넘어갈 때마다 소지된 아이템 중 하나를 제거합니다. 제거된 아이템과 " .. rhongomyniadEIDString .. " 중 하나를 소환합니다. 하나를 선택하면 나머지는 사라집니다.")
        end
    end
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.RHONGOMYNIAD) then
                local inventory = AstroItems:getPlayerInventory(player, false)
                local rng = player:GetCollectibleRNG(AstroItems.Collectible.RHONGOMYNIAD)
                local optionsPickupIndex = AstroItems.Collectible.RHONGOMYNIAD + i * 10000

                local hadCollectable = AstroItems:GetRandomCollectibles(inventory, rng, 1, AstroItems.Collectible.RHONGOMYNIAD, true)[1]

                local list = {}

                for _, collectible in ipairs(AstroItems.CleanerList) do
                    if collectible ~= hadCollectable then
                        table.insert(list, collectible)
                    end
                end

                if #list ~= 0 then
                    local random = rng:RandomInt(#list) + 1

                    if hadCollectable ~= nil then
                        player:RemoveCollectible(hadCollectable)
                        AstroItems:SpawnCollectible(hadCollectable, player.Position, optionsPickupIndex)
                    end

                    AstroItems:SpawnCollectible(list[random], player.Position, optionsPickupIndex)
                end
            end
        end
    end
)

local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS = Isaac.GetItemIdByName("Duality - Light and Darkness")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS, "표리일체", "...", "스테이지 입장 시 {{Collectible675}}Cracked Orb, {{Collectible691}}Sacred Orb, {{Collectible" .. AstroItems.Collectible.FALLEN_ORB .. "}}Fallen Orb를 제거합니다.#스테이지 입장 시 소지된 아이템 중 하나를 제거합니다. 제거된 아이템과 {{Collectible675}}Cracked Orb, {{Collectible691}}Sacred Orb, {{Collectible" .. AstroItems.Collectible.FALLEN_ORB .. "}}Fallen Orb 중 하나를 소환합니다. 하나를 선택하면 나머지는 사라집니다.#!!! 이번 게임에서 {{Collectible675}}Cracked Orb, {{Collectible691}}Sacred Orb, {{Collectible" .. AstroItems.Collectible.FALLEN_ORB .. "}}Fallen Orb가 등장하지 않습니다.")
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()

        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB)
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB)
        itemPool:RemoveCollectible(AstroItems.Collectible.FALLEN_ORB)
    end,
    AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS
)

AstroItems:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS) then
                player:RemoveCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB)
                player:RemoveCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB)
                player:RemoveCollectible(AstroItems.Collectible.FALLEN_ORB)

                local inventory = AstroItems:getPlayerInventory(player, false)
                local rng = player:GetCollectibleRNG(AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS)

                local hadCollectable = AstroItems:GetRandomCollectibles(inventory, rng, 1, AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS, true)

                if hadCollectable[1] ~= nil then
                    player:RemoveCollectible(hadCollectable[1])
                    AstroItems:SpawnCollectible(hadCollectable[1], player.Position, AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS)
                end

                local random = rng:RandomInt(3)

                if random == 0 then
                    AstroItems:SpawnCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB, player.Position, AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS)
                elseif random == 1 then
                    AstroItems:SpawnCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB, player.Position, AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS)
                else
                    AstroItems:SpawnCollectible(AstroItems.Collectible.FALLEN_ORB, player.Position, AstroItems.Collectible.DUALITY_LIGHT_AND_DARKNESS)
                end
            end
        end
    end
)

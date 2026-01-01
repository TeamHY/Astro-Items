local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS = Isaac.GetItemIdByName("Duality - Light and Darkness")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function(_)
        if EID then
            Astro.EID:AddCollectible(
                Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS,
                "표리일체",
                "반짝이는 수수께끼",
                "!!! 획득 이후 {{Collectible675}}Cracked Orb, {{Collectible691}}Sacred Orb, {{Collectible" .. Astro.Collectible.FALLEN_ORB .. "}}Fallen Orb 미등장" ..
                "#스테이지를 넘어갈 때마다 소지중인 아이템 중 하나와 {{Collectible675}}/{{Collectible691}}/{{Collectible" .. Astro.Collectible.FALLEN_ORB .. "}}를 제거하며;" ..
                "#{{ArrowGrayRight}} 제거된 아이템과 {{Collectible675}}/{{Collectible691}}/{{Collectible" .. Astro.Collectible.FALLEN_ORB .. "}} 중 하나를 소환합니다." ..
                "#{{ArrowGrayRight}} 소환된 아이템 중 하나를 선택하면 나머지는 사라집니다."
            )
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()

        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB)
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB)
        itemPool:RemoveCollectible(Astro.Collectible.FALLEN_ORB)
    end,
    Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS
)

Astro:AddCallback(
    ModCallbacks.MC_POST_NEW_LEVEL,
    function()
        for i = 1, Game():GetNumPlayers() do
            local player = Isaac.GetPlayer(i - 1)

            if player:HasCollectible(Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS) then
                player:RemoveCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB)
                player:RemoveCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB)
                player:RemoveCollectible(Astro.Collectible.FALLEN_ORB)

                local inventory = Astro:getPlayerInventory(player, false)
                local rng = player:GetCollectibleRNG(Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS)

                local hadCollectable = Astro:GetRandomCollectibles(inventory, rng, 1, Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS, true)

                if hadCollectable[1] ~= nil then
                    player:RemoveCollectible(hadCollectable[1])
                    Astro:SpawnCollectible(hadCollectable[1], player.Position, Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS)
                end

                local random = rng:RandomInt(3)

                if random == 0 then
                    Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB, player.Position, Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS)
                elseif random == 1 then
                    Astro:SpawnCollectible(CollectibleType.COLLECTIBLE_SACRED_ORB, player.Position, Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS)
                else
                    Astro:SpawnCollectible(Astro.Collectible.FALLEN_ORB, player.Position, Astro.Collectible.DUALITY_LIGHT_AND_DARKNESS)
                end
            end
        end
    end
)

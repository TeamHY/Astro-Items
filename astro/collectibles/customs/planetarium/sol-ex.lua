local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SOL_EX = Isaac.GetItemIdByName("SOL EX")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SOL_EX,
        "초 태양",
        "...",
        "{{Collectible588}}Sol 효과가 적용되고 해당 게임에서 등장하지 않습니다." ..
        "#{{BossRoom}}보스방 클리어 시 {{Collectible633}}Dogma를 획득하고 황금 장신구 2개를 소환합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    ---@param rng RNG
    ---@param spawnPosition Vector
    function(_, rng, spawnPosition)
        local level = Game():GetLevel()
        local currentRoom = level:GetCurrentRoom()
        local itemPool = Game():GetItemPool()

        if currentRoom:GetType() == RoomType.ROOM_BOSS then
            for i = 1, Game():GetNumPlayers() do
                local player = Isaac.GetPlayer(i - 1)

                if player:HasCollectible(Astro.Collectible.SOL_EX) then
                    for _ = 1, player:GetCollectibleNum(Astro.Collectible.SOL_EX) do
                        player:AddCollectible(CollectibleType.COLLECTIBLE_DOGMA)
    
                        for _ = 1, 2 do
                            Astro:SpawnTrinket(itemPool:GetTrinket() + 32768, player.Position)
                        end
                    end
                end
            end
        end
    end
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SOL)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SOL) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SOL)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    Astro.Collectible.SOL_EX
)

-- Astro:AddCallbackCustom(
--     isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
--     ---@param player EntityPlayer
--     ---@param collectibleType CollectibleType
--     function(_, player, collectibleType)
--         if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SOL) then
--             hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SOL)
--             Game():GetLevel():UpdateVisibility()
--         end
--     end,
--     Astro.Collectible.SOL_EX
-- )

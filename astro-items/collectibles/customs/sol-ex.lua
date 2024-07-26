local isc = require("astro-items.lib.isaacscript-common")
local hiddenItemManager = require("astro-items.lib.hidden_item_manager")

AstroItems.Collectible.SOL_EX = Isaac.GetItemIdByName("SOL EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.SOL_EX,
        "초 태양",
        "...",
        EID:getDescriptionObj(5, 100, CollectibleType.COLLECTIBLE_SOL, nil, false).Description ..
        "#황금 장신구 2개를 소환합니다." ..
        "#{{Collectible633}}Dogma를 획득합니다."
    )
end

AstroItems:AddCallback(
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

                if player:HasCollectible(AstroItems.Collectible.SOL_EX) then
                    for _ = 1, player:GetCollectibleNum(AstroItems.Collectible.SOL_EX) do
                        player:AddCollectible(CollectibleType.COLLECTIBLE_DOGMA)
    
                        for _ = 1, 2 do
                            AstroItems:SpawnTrinket(itemPool:GetTrinket() + 32768, player.Position)
                        end
                    end
                end
            end
        end
    end
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SOL) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_SOL)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    AstroItems.Collectible.SOL_EX
)

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_SOL) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_SOL)
            Game():GetLevel():UpdateVisibility()
        end
    end,
    AstroItems.Collectible.SOL_EX
)

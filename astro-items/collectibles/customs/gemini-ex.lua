local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.GEMINI_EX = Isaac.GetItemIdByName("Gemini EX")

if EID then
    AstroItems:AddEIDCollectible(
        AstroItems.Collectible.GEMINI_EX,
        "초 쌍둥이자리",
        "...",
        "현재 소지중인 아이템에서 랜덤하게 5개를 소환합니다. 하나를 선택하면 나머지는 사라집니다."
    )
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if AstroItems:IsFirstAdded(AstroItems.Collectible.GEMINI_EX) then
            local level = Game():GetLevel()
            local currentRoom = level:GetCurrentRoom()
            local rng = player:GetCollectibleRNG(AstroItems.Collectible.GEMINI_EX)
            local inventory = AstroItems:getPlayerInventory(player, false)

            local listToSpawn = AstroItems:GetRandomCollectibles(inventory, rng, 5, AstroItems.Collectible.GEMINI_EX, true)

            for key, value in ipairs(listToSpawn) do
                AstroItems:SpawnCollectible(value, player.Position + Vector(AstroItems.GRID_SIZE * (-3 + key), -AstroItems.GRID_SIZE), AstroItems.Collectible.GEMINI_EX)
            end
        end
    end,
    AstroItems.Collectible.GEMINI_EX
)

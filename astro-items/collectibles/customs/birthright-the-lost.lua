local isc = require("astro-items.lib.isaacscript-common")

AstroItems.Collectible.BIRTHRIGHT_THE_LOST = Isaac.GetItemIdByName("Birthright - The Lost")

if EID then
    AstroItems:AddEIDCollectible(AstroItems.Collectible.BIRTHRIGHT_THE_LOST, "생득권 - 로스트", "...", "획득 시 로스트에게 불필요한 아이템이 배열에서 제거됩니다.")
end

AstroItems:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()

        for _, config in ipairs(AstroItems.CollectableConfigs) do
            if config:HasTags(ItemConfig.TAG_NO_LOST_BR) then
                itemPool:RemoveCollectible(config.ID)
            end
        end
    end,
    AstroItems.Collectible.BIRTHRIGHT_THE_LOST
)

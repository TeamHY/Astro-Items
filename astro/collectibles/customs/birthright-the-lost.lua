local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_THE_LOST = Isaac.GetItemIdByName("Birthright - The Lost")

if EID then
    Astro:AddEIDCollectible(Astro.Collectible.BIRTHRIGHT_THE_LOST, "더 로스트의 생득권", "더 나은 운명", "획득 시 The Lost에게 불필요한 아이템이 배열에서 제거됩니다.")
end

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_ADDED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        local itemPool = Game():GetItemPool()

        for _, config in ipairs(Astro.CollectableConfigs) do
            if config:HasTags(ItemConfig.TAG_NO_LOST_BR) then
                itemPool:RemoveCollectible(config.ID)
            end
        end
    end,
    Astro.Collectible.BIRTHRIGHT_THE_LOST
)

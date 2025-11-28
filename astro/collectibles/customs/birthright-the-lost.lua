local isc = require("astro.lib.isaacscript-common")

Astro.Collectible.BIRTHRIGHT_THE_LOST = Isaac.GetItemIdByName("The Lost's Frame")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.BIRTHRIGHT_THE_LOST,
        "더 로스트의 액자",
        "더 나은 운명",
        "{{Player10}} 체력 증가, 비행 능력, 공격 지형 관통 효과만 부여되는 아이템과 피격 시 발동되는 류의 아이템이 등장하지 않습니다."
    )
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

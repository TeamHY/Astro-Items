local isc = require("astro.lib.isaacscript-common")
local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.URANUS_EX = Isaac.GetItemIdByName("URANUS EX")

Astro:AddCallback(
    Astro.Callbacks.MOD_INIT,
    function()
        if EID then
            Astro:AddEIDCollectible(
                Astro.Collectible.URANUS_EX,
                "초 천왕성",
                "꽁꽁꽁",
                "!!! 획득 이후 {{Collectible596}}Uranus 미등장" ..
                "#{{Freezing}} 적 처치시 적이 얼어붙으며;" ..
                "#{{ArrowGrayRight}} {{Collectible596}}얼어붙은 적은 접촉 시 직선으로 날아가 10방향으로 고드름 눈물을 발사합니다." ..
                "#{{Collectible530}} {{DeathMark}}해골마크가 뜬 적을 순차적으로 처치시 픽업이 드랍되거나 랜덤 능력치가 하나 증가합니다."
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
        itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_URANUS)

        if not hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_URANUS) then
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_URANUS)
            hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_DEATHS_LIST)
        end
    end,
    Astro.Collectible.URANUS_EX
)

Astro:AddCallbackCustom(
    isc.ModCallbackCustom.POST_PLAYER_COLLECTIBLE_REMOVED,
    ---@param player EntityPlayer
    ---@param collectibleType CollectibleType
    function(_, player, collectibleType)
        if hiddenItemManager:Has(player, CollectibleType.COLLECTIBLE_URANUS) then
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_URANUS)
            hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_DEATHS_LIST)
        end
    end,
    Astro.Collectible.URANUS_EX
)

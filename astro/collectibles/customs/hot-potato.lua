---

local EXPLOSION_INTERVAL = 120

---

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.HOT_POTATO = Isaac.GetItemIdByName("Hot Potato")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.HOT_POTATO,
        "뜨거운 감자",
        "",
        "4초마다 폭발을 일으킵니다." ..
        "#{{Collectible375}}Host Hat 효과가 적용됩니다."..
        "#폭탄 +2 증가됩니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.HOT_POTATO) then
            return
        end

        local data = Astro:GetPersistentPlayerData(player)
        local room = Game():GetRoom()

        data.hotPotatoCounter = (data.hotPotatoCounter or 0) + 1

        if data.hotPotatoCounter >= EXPLOSION_INTERVAL and not room:IsClear() then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_KAMIKAZE, false)
            
            data.hotPotatoCounter = 0
        end

        hiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_HOST_HAT, 1, "ASTRO_HOT_POTATO")
    end
)

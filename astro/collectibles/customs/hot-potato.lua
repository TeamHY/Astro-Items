---

local EXPLOSION_INTERVAL = 120

---

local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.HOT_POTATO = Isaac.GetItemIdByName("Hot Potato")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.HOT_POTATO,
        "뜨거운 감자",
        "화젯거리",
        "↑ {{Bomb}}폭탄 +2"..
        "#{{Collectible40}} 4초마다 캐릭터의 위치에 공격력 185의 폭발을 일으킵니다." ..
        "#{{Collectible375}} 폭발 공격에 피해를 입지 않게 되며;" ..
        "#{{ArrowGrayRight}} 적 탄환에 맞았을 때 20% 확률로 피해를 무시하며 캐릭터의 눈물과 같은 눈물을 3발 발사하며;" ..
        "#{{ArrowGrayRight}} 위에서 떨어지는 탄막에 피해를 받지 않습니다."
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

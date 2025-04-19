local hiddenItemManager = require("astro.lib.hidden_item_manager")

Astro.Collectible.SCHRODINGERS_CAT = Isaac.GetItemIdByName("Schrodinger's Cat")
Astro.Collectible.GUPPY_PART = Isaac.GetItemIdByName("Guppy Part")

if EID then
    Astro:AddEIDCollectible(
        Astro.Collectible.SCHRODINGERS_CAT,
        "슈뢰딩거의 고양이",
        "",
        "클리어 되지 않은 방 입장 시 50% 확률로 Guppy 세트 카운트가 1 증가합니다. 방을 나가면 사라집니다. 중첩이 가능합니다."
    )
end

Astro:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    ---@param player EntityPlayer
    function(_, player)
        if not player:HasCollectible(Astro.Collectible.SCHRODINGERS_CAT) then
            return
        end

        local room = Game():GetRoom()

        hiddenItemManager:CheckStack(player, Astro.Collectible.GUPPY_PART, room:IsClear() and 0 or player:GetCollectibleNum(Astro.Collectible.SCHRODINGERS_CAT), "ASTRO_SCHRODINGERS_CAT")
    end
)
